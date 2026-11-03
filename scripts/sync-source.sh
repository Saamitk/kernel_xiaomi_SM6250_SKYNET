#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# sync-source.sh -- fetch the exact pinned reference kernel into ./kernel.
# The fetched tree is gitignored and must never be committed to this repository.

set -euo pipefail

readonly UPSTREAM_URL="https://github.com/AzyrRuthless/kernel_xiaomi_sm6250.git"
readonly UPSTREAM_BRANCH="16"
readonly PINNED_COMMIT="4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183"
readonly EXPECTED_VERSION="4.14.357"
readonly EXPECTED_EXTRAVERSION="-openela"
readonly DEFCONFIG_REL="arch/arm64/configs/vendor/xiaomi/miatoll_defconfig"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-${REPO_ROOT}/kernel}"

usage() {
    cat <<'USAGE'
Usage: scripts/sync-source.sh [options]

  (no options)  Fetch the pinned kernel source into ./kernel (gitignored).
  --check       Only verify that the pin in the script and docs agree. No network.
  --force       Replace an existing ./kernel directory that is not at the pin.
  -h, --help    Show this help.

Environment:
  KERNEL_DIR    Override the destination directory (default: <repo>/kernel).
USAGE
}

log() { printf '[sync] %s\n' "$*"; }
die() { printf '[sync] ERROR: %s\n' "$*" >&2; exit 1; }

check_docs() {
    local f
    for f in "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/UPSTREAM.md"; do
        [[ -f "$f" ]] || die "missing documentation: $f"
        grep -qF "$PINNED_COMMIT" "$f" || die "$f does not mention the pinned commit"
        grep -qF "$EXPECTED_VERSION" "$f" || die "$f does not mention kernel $EXPECTED_VERSION"
    done
    log "documentation pin is consistent ($PINNED_COMMIT, $EXPECTED_VERSION)"
}

FORCE=0
CHECK_ONLY=0
while (($#)); do
    case "$1" in
        --check) CHECK_ONLY=1; shift ;;
        --force) FORCE=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1 (try --help)" ;;
    esac
done

check_docs
if ((CHECK_ONLY)); then
    log "check-only mode: nothing was downloaded"
    exit 0
fi

command -v git >/dev/null 2>&1 || die "git is required"
[[ "$KERNEL_DIR" != "$REPO_ROOT" ]] || die "KERNEL_DIR must not be the repository root"

if [[ -e "$KERNEL_DIR" ]]; then
    CURRENT="$(git -C "$KERNEL_DIR" rev-parse HEAD 2>/dev/null || printf 'none')"
    if [[ "$CURRENT" == "$PINNED_COMMIT" ]]; then
        log "already at $PINNED_COMMIT -- nothing to do"
    else
        ((FORCE)) || die "$KERNEL_DIR exists but is not at the pin; re-run with --force to replace it"
        log "removing stale $KERNEL_DIR"
        rm -rf -- "$KERNEL_DIR"
    fi
fi

if [[ ! -d "$KERNEL_DIR/.git" ]]; then
    mkdir -p "$KERNEL_DIR"
    git -C "$KERNEL_DIR" init -q
    git -C "$KERNEL_DIR" remote add origin "$UPSTREAM_URL"
    log "fetching $UPSTREAM_BRANCH @ $PINNED_COMMIT"
    if ! git -C "$KERNEL_DIR" fetch -q --depth=1 origin "$PINNED_COMMIT"; then
        log "fetch by SHA was refused; falling back to branch $UPSTREAM_BRANCH"
        git -C "$KERNEL_DIR" fetch -q --depth=200 origin "$UPSTREAM_BRANCH"
    fi
    git -C "$KERNEL_DIR" checkout -q --detach "$PINNED_COMMIT"
fi

HEAD="$(git -C "$KERNEL_DIR" rev-parse HEAD)"
[[ "$HEAD" == "$PINNED_COMMIT" ]] || die "unexpected HEAD: $HEAD"

MAKEFILE="$KERNEL_DIR/Makefile"
[[ -f "$MAKEFILE" ]] || die "Makefile missing from the fetched tree"
VERSION="$(sed -n -e 's/^VERSION = //p' -e 's/^PATCHLEVEL = //p' -e 's/^SUBLEVEL = //p' "$MAKEFILE" | paste -sd. -)"
[[ "$VERSION" == "$EXPECTED_VERSION" ]] || die "expected kernel $EXPECTED_VERSION, got $VERSION"
EXTRAVERSION="$(sed -n 's/^EXTRAVERSION = //p' "$MAKEFILE")"
[[ "$EXTRAVERSION" == "$EXPECTED_EXTRAVERSION" ]] || die "expected EXTRAVERSION $EXPECTED_EXTRAVERSION, got $EXTRAVERSION"
[[ -f "$KERNEL_DIR/$DEFCONFIG_REL" ]] || die "defconfig missing: $DEFCONFIG_REL"

log "kernel ${VERSION}${EXTRAVERSION} ready at $KERNEL_DIR"
log "defconfig: $DEFCONFIG_REL"
log "next: scripts/build.sh --clang-dir /path/to/clang/bin"
