#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# build.sh -- reproducible defconfig + Clang/LLD build wrapper for the Miatoll kernel.
# The kernel source lives at the repository root (or in kernel/ before the
# flatten workflow has run); both layouts are detected automatically.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$REPO_ROOT/Makefile" && \
      -f "$REPO_ROOT/arch/arm64/configs/vendor/xiaomi/miatoll_defconfig" ]]; then
    DEFAULT_KERNEL_DIR="$REPO_ROOT"
else
    DEFAULT_KERNEL_DIR="$REPO_ROOT/kernel"
fi

KERNEL_DIR="${KERNEL_DIR:-$DEFAULT_KERNEL_DIR}"
OUT_DIR="${OUT_DIR:-${KERNEL_DIR}/out}"
DEFCONFIG="${DEFCONFIG:-vendor/xiaomi/miatoll_defconfig}"
TARGET="${TARGET:-Image.gz-dtb}"
JOBS="${JOBS:-$(nproc)}"
CLANG_DIR="${CLANG_DIR:-}"
CROSS_COMPILE="${CROSS_COMPILE:-aarch64-linux-gnu-}"
CROSS_COMPILE_COMPAT="${CROSS_COMPILE_COMPAT:-arm-linux-gnueabi-}"
CLANG_TRIPLE="${CLANG_TRIPLE:-aarch64-linux-gnu-}"
DRY_RUN=0
CLEAN=0
MENUCONFIG=0
NO_POLLY=0

usage() {
    cat <<'USAGE'
Usage: scripts/build.sh [options]

  --kernel-dir DIR   Kernel source (auto-detected: repo root or kernel/).
  --out DIR          Build output directory (default: <kernel>/out).
  --clang-dir DIR    Prepend DIR to PATH (Clang/LLD/LLVM tools).
  --defconfig NAME   Defconfig target (default: vendor/xiaomi/miatoll_defconfig).
  --target NAME      Make target (default: Image.gz-dtb).
  --jobs N           Parallel jobs (default: nproc).
  --clean            Run mrproper before configuring.
  --menuconfig       Open menuconfig after configuring, then stop.
  --no-polly         Disable CONFIG_LLVM_POLLY (for Clang builds without Polly).
  --dry-run          Print the make commands without running them.
  -h, --help         Show this help.

Environment (same names, without leading dashes):
  KERNEL_DIR, OUT_DIR, DEFCONFIG, TARGET, JOBS, CLANG_DIR,
  CROSS_COMPILE, CROSS_COMPILE_COMPAT, CLANG_TRIPLE
USAGE
}

log() { printf '[build] %s\n' "$*"; }
die() { printf '[build] ERROR: %s\n' "$*" >&2; exit 1; }
run() {
    printf '  '
    printf '%q ' "$@"
    printf '\n'
    if ((!DRY_RUN)); then
        "$@"
    fi
}

while (($#)); do
    case "$1" in
        --kernel-dir) KERNEL_DIR="${2:?--kernel-dir needs a value}"; shift 2 ;;
        --out) OUT_DIR="${2:?--out needs a value}"; shift 2 ;;
        --clang-dir) CLANG_DIR="${2:?--clang-dir needs a value}"; shift 2 ;;
        --defconfig) DEFCONFIG="${2:?--defconfig needs a value}"; shift 2 ;;
        --target) TARGET="${2:?--target needs a value}"; shift 2 ;;
        --jobs) JOBS="${2:?--jobs needs a value}"; shift 2 ;;
        --clean) CLEAN=1; shift ;;
        --menuconfig) MENUCONFIG=1; shift ;;
        --no-polly) NO_POLLY=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1 (try --help)" ;;
    esac
done

[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || die "--jobs must be a positive integer"
[[ -f "$KERNEL_DIR/Makefile" ]] \
    || die "no kernel source at $KERNEL_DIR -- run .github/workflows/flatten-source.yml"
log "source: $KERNEL_DIR"

if [[ -n "$CLANG_DIR" ]]; then
    [[ -d "$CLANG_DIR" ]] || die "clang dir not found: $CLANG_DIR"
    export PATH="${CLANG_DIR}:${PATH}"
fi

if ((!DRY_RUN)); then
    for tool in clang ld.lld llvm-ar llvm-nm llvm-objcopy; do
        command -v "$tool" >/dev/null 2>&1 \
            || die "missing tool: $tool (install Clang/LLVM or pass --clang-dir)"
    done
    log "$(clang --version | head -n1)"
    log "$(ld.lld --version | head -n1)"
fi

if [[ "$OUT_DIR" != /* ]]; then
    OUT_DIR="$(pwd)/${OUT_DIR}"
fi
if ((!DRY_RUN)); then
    mkdir -p "$OUT_DIR"
fi

MAKE_ARGS=(
    -C "$KERNEL_DIR" O="$OUT_DIR" ARCH=arm64
    HOSTCC=gcc HOSTCXX=g++ HOSTLD=ld
    CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip
    CLANG_TRIPLE="$CLANG_TRIPLE"
    CROSS_COMPILE="$CROSS_COMPILE"
    CROSS_COMPILE_ARM32="$CROSS_COMPILE_COMPAT"
    CROSS_COMPILE_COMPAT="$CROSS_COMPILE_COMPAT"
)

if ((CLEAN)); then
    run make "${MAKE_ARGS[@]}" mrproper
fi

log "defconfig: $DEFCONFIG"
run make "${MAKE_ARGS[@]}" "$DEFCONFIG"

# CONFIG_LLVM_POLLY=y injects -mllvm -polly-* flags that prebuilt Clang
# toolchains without Polly reject (e.g. proton-clang). Disable it for those
# builds; the resulting kernel is otherwise identical.
if ((NO_POLLY)); then
    log "disabling CONFIG_LLVM_POLLY (toolchain without Polly)"
    run "$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" -d LLVM_POLLY
fi

run make "${MAKE_ARGS[@]}" olddefconfig

if ((MENUCONFIG)); then
    run make "${MAKE_ARGS[@]}" menuconfig
    log "menuconfig finished; run again without --menuconfig to build"
    exit 0
fi

log "building $TARGET with -j$JOBS"
run make "${MAKE_ARGS[@]}" -j"$JOBS" "$TARGET"
log "done -- artefacts: $OUT_DIR/arch/arm64/boot/"
