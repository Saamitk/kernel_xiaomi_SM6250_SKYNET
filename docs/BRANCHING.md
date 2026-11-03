# Branching, tags and releases

## What "17" means

`17` is a **generation line label**, not a Linux kernel version. The reference tree numbers its
lines `16` and `16-5.4`; this project's next line is `17`. The kernel remains
`4.14.357-openela` until the upstream pin is deliberately changed (see
[`docs/UPSTREAM.md`](UPSTREAM.md)).

## Branch model

| Branch | Role |
| --- | --- |
| `main` | Stable source, documentation and tooling. PRs land here first. |
| `17` | Development line for the next generation of builds and config changes. |
| `arena/a96b7a0b-kernel-xiaomi-sm6250-skynet` | Arena working branch used for the flatten + AnyKernel3 pass; merged into `main` via PR. |
| topic branches | Short-lived branches for a single PR (`arm64/...`, `scripts/...`, `ci/...`). |

The Arena session is tied to its working branch and cannot create or push other branches. The `17`
branch must be created by the maintainer, once, after this PR merges.

## Creating the `17` branch

```bash
git fetch origin
git switch -c 17 origin/main
git push -u origin 17
```

Optionally make it the default branch:

```bash
gh api -X PATCH repos/Saamitk/kernel_xiaomi_SM6250_SKYNET -f default_branch=17
```

Keep `main` as the stable landing branch. `build-kernel.yml` runs on `workflow_dispatch`, on
`skynet-17-*` tags, and when its own workflow/build/packaging files change — so most commits do
not trigger a 30-minute kernel build. Run it manually from the Actions tab for a release.

## Tags and release names

Use `skynet-17-r<N>`, for example `skynet-17-r1`. Attach to each release:

- the flashable AnyKernel3 ZIP and its SHA-256;
- `kernel.release`, e.g. `4.14.357-openela-SKYNET`;
- the defconfig used (`vendor/xiaomi/miatoll_defconfig`) and `out/.config`;
- the exact source commit and any local patches;
- Clang and LLD versions plus `skynet-build.prop` from the ZIP;
- the devices/ROMs it was tested on.

## Release checklist

1. `./scripts/verify-source.sh` and `python3 scripts/check-links.py` pass.
2. `./scripts/build.sh --dry-run` matches the commands recorded in the release notes.
3. Clean build from the in-tree source; archive `out/.config`.
4. Package with `scripts/package-anykernel.sh` (or run the `Build SKYNET kernel` workflow).
5. Verify `anykernel.sh` block/slot settings and the ZIP contents; see
   [`docs/RELEASING.md`](RELEASING.md).
6. Test on at least one device (see [`docs/DEVICES.md`](DEVICES.md)) and confirm Wi-Fi, BT,
   camera, fingerprint, audio, charging and deep sleep.
7. Add a [`CHANGELOG.md`](../CHANGELOG.md) entry and tag the commit.
8. Upload the ZIP, checksum and provenance to the GitHub Release.

Contributions follow [`../CONTRIBUTING.md`](../CONTRIBUTING.md).
