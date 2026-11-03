#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# verify-source.sh -- check the in-tree kernel source and the documentation pin.
# Fully offline. Works both before and after the flatten workflow has run.

set -euo pipefail

readonly PINNED_COMMIT="4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183"
readonly EXPECTED_VERSION="4.14.357"
readonly EXPECTED_EXTRAVERSION="-openela"
readonly DEFCONFIG_REL="arch/arm64/configs/vendor/xiaomi/miatoll_defconfig"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
    cat <<'USAGE'
Usage: scripts/verify-source.sh [--check]

Verifies, without any network access:
  * README.md and docs/UPSTREAM.md quote the same pinned commit and version;
  * the kernel source is present (at the root, or in kernel/ before flattening);
  * Makefile reports 4.14.357-openela;
  * the Miatoll defconfig exists.

--check is accepted as a no-op alias for CI compatibility.
USAGE
}

log() { printf '[verify] %s\n' "$*"; }
die() { printf '[verify] ERROR: %s\n' "$*" >&2; exit 1; }

case "${1:-}" in
    --check|'') ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
esac

for f in "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/UPSTREAM.md"; do
    [[ -f "$f" ]] || die "missing documentation: $f"
    grep -qF "$PINNED_COMMIT" "$f" || die "$f does not quote the pinned commit"
    grep -qF "$EXPECTED_VERSION" "$f" || die "$f does not quote kernel $EXPECTED_VERSION"
done
log "documentation pin is consistent ($PINNED_COMMIT, $EXPECTED_VERSION)"

if [[ -f "$REPO_ROOT/Makefile" && -f "$REPO_ROOT/$DEFCONFIG_REL" ]]; then
    SRC="$REPO_ROOT"
    LAYOUT="repository root"
    COUNT="$(git -C "$REPO_ROOT" ls-files | wc -l)"
elif [[ -f "$REPO_ROOT/kernel/Makefile" && -f "$REPO_ROOT/kernel/$DEFCONFIG_REL" ]]; then
    SRC="$REPO_ROOT/kernel"
    LAYOUT="kernel/ (pre-flatten layout)"
    COUNT="$(git -C "$REPO_ROOT" ls-files kernel | wc -l)"
else
    die "kernel source not found; run .github/workflows/flatten-source.yml"
fi

VERSION="$(sed -n -e 's/^VERSION = //p' -e 's/^PATCHLEVEL = //p' \
    -e 's/^SUBLEVEL = //p' "$SRC/Makefile" | paste -sd. -)"
[[ "$VERSION" == "$EXPECTED_VERSION" ]] \
    || die "expected kernel $EXPECTED_VERSION, got $VERSION"
EXTRAVERSION="$(sed -n 's/^EXTRAVERSION = //p' "$SRC/Makefile")"
[[ "$EXTRAVERSION" == "$EXPECTED_EXTRAVERSION" ]] \
    || die "expected EXTRAVERSION $EXPECTED_EXTRAVERSION, got $EXTRAVERSION"
[[ -f "$SRC/$DEFCONFIG_REL" ]] || die "defconfig missing: $DEFCONFIG_REL"

log "source layout: $LAYOUT"
log "kernel ${VERSION}${EXTRAVERSION}, defconfig $DEFCONFIG_REL"
log "$COUNT tracked files; source verification passed"
