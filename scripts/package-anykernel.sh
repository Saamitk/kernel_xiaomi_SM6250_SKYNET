#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# package-anykernel.sh -- assemble a flashable AnyKernel3 ZIP from a local build.
# Clones the upstream AnyKernel3 framework, overlays SKYNET's anykernel.sh,
# drops in the built images and writes a provenance file.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AK3_REPO="${AK3_REPO:-https://github.com/osm0sis/AnyKernel3.git}"
AK3_REF="${AK3_REF:-master}"
NAME="${NAME:-skynet-17}"
OUT="${OUT:-$REPO_ROOT/$NAME.zip}"
OUT_DIR="${OUT_DIR:-$REPO_ROOT/out}"
AK3_DIR="${AK3_DIR:-}"
DRY_RUN=0

usage() {
    cat <<'USAGE'
Usage: scripts/package-anykernel.sh [options]

  --name NAME      Base name of the ZIP (default: skynet-17).
  --out PATH       Output ZIP path (default: <repo>/<name>.zip).
  --out-dir DIR    Kernel build output (default: <repo>/out).
  --ak3-dir DIR    Use an existing AnyKernel3 checkout instead of cloning.
  --dry-run        Print what would be packaged; build nothing.
  -h, --help       Show this help.
USAGE
}

log() { printf '[package] %s\n' "$*"; }
die() { printf '[package] ERROR: %s\n' "$*" >&2; exit 1; }

while (($#)); do
    case "$1" in
        --name) NAME="${2:?--name needs a value}"; shift 2 ;;
        --out) OUT="${2:?--out needs a value}"; shift 2 ;;
        --out-dir) OUT_DIR="${2:?--out-dir needs a value}"; shift 2 ;;
        --ak3-dir) AK3_DIR="${2:?--ak3-dir needs a value}"; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1 (try --help)" ;;
    esac
done

BOOT="$OUT_DIR/arch/arm64/boot"
[[ -d "$BOOT" ]] || die "no build output at $BOOT -- build the kernel first"
[[ -f "$REPO_ROOT/anykernel3/anykernel.sh" ]] || die "missing anykernel3/anykernel.sh"

IMAGES=()
for f in Image.gz-dtb Image.gz dtbo.img; do
    [[ -f "$BOOT/$f" ]] && IMAGES+=("$f")
done
((${#IMAGES[@]})) || die "no kernel image found in $BOOT (build Image.gz-dtb first)"
log "images: ${IMAGES[*]}"

if ((DRY_RUN)); then
    log "dry-run: would build $OUT from ${IMAGES[*]} + AnyKernel3 ($AK3_REF)"
    exit 0
fi

command -v zip >/dev/null 2>&1 || die "zip is required"
command -v git >/dev/null 2>&1 || die "git is required"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ -n "$AK3_DIR" ]]; then
    STAGE="$TMP/ak3"
    cp -a "$AK3_DIR/." "$STAGE/"
else
    STAGE="$TMP/ak3"
    git clone -q --depth 1 -b "$AK3_REF" "$AK3_REPO" "$STAGE"
fi

[[ -f "$STAGE/tools/ak3-core.sh" ]] || die "not an AnyKernel3 checkout: $STAGE"
[[ -f "$STAGE/META-INF/com/google/android/update-binary" ]] \
    || die "AnyKernel3 update-binary missing"

cp -a "$REPO_ROOT/anykernel3/anykernel.sh" "$STAGE/anykernel.sh"
for f in "${IMAGES[@]}"; do
    cp -a "$BOOT/$f" "$STAGE/$f"
done

RELEASE="$(cat "$OUT_DIR/include/config/kernel.release" 2>/dev/null || printf 'unknown')"
COMMIT="$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || printf 'unknown')"
DEFCONFIG="$(grep -m1 '^CONFIG_LOCALVERSION=' "$REPO_ROOT/arch/arm64/configs/vendor/xiaomi/miatoll_defconfig" 2>/dev/null || printf 'unknown')"

cat > "$STAGE/skynet-build.prop" <<EOF
# SKYNET 17 build provenance
name=$NAME
kernel.release=$RELEASE
defconfig=vendor/xiaomi/miatoll_defconfig
localversion=$DEFCONFIG
source.commit=$COMMIT
source.pin=$(grep -m1 -oE '[0-9a-f]{40}' "$REPO_ROOT/docs/UPSTREAM.md" || printf 'unknown')
images=${IMAGES[*]}
built.utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

rm -rf "$STAGE/.git"
( cd "$STAGE" && zip -r9 -q "$OUT" . -x '*.git*' )
log "wrote $OUT"
log "sha256: $(sha256sum "$OUT" | cut -d' ' -f1)"
