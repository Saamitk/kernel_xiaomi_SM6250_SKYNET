# Branching, tags and releases

## What "17" means

`17` is a **generation line label**, not a Linux kernel version. The reference tree numbers its
lines `16` and `16-5.4`; this project's next line is `17`. The kernel itself remains
`4.14.357-openela` until the upstream pin is deliberately changed (see
[`docs/UPSTREAM.md`](UPSTREAM.md)).

## Branch model

| Branch | Role |
| --- | --- |
| `main` | Stable documentation and tooling. PRs land here first. |
| `17` | Development line for the next generation of builds and config changes. |
| `arena/0b00731c-kernel-xiaomi-sm6250-skynet` | Arena working branch used to prepare this scaffold; merged into `main` via PR. |
| topic branches | Short-lived branches for a single PR (`docs/...`, `scripts/...`, `ci/...`). |

The Arena session that prepared this repository is tied to its working branch and cannot create or
push other branches. The `17` branch therefore has to be created by the maintainer, once, after the
scaffold PR is merged.

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

Keep `main` as the docs/release landing page; merge `17` into `main` for each release, or tag
release commits directly from `17` — just be consistent and state the choice in the release notes.

## Tags and release names

Use `skynet-17-r<N>` for the first line, for example `skynet-17-r1`. Attach to each release:

- the AnyKernel3 flashable ZIP (and its SHA-256);
- `kernel.release`, e.g. `4.14.357-openela-kinesis-omega-bpf`;
- the defconfig used (`vendor/xiaomi/miatoll_defconfig`);
- the exact source commit (the pin) and any local patches;
- Clang and LLD versions plus `out/.config`;
- the devices/ROMs it was tested on.

## Release checklist

1. `./scripts/sync-source.sh --check` and `python3 scripts/check-links.py` pass.
2. `./scripts/build.sh --dry-run` matches the commands recorded in the release notes.
3. Clean build from the pinned source; archive `out/.config`.
4. Package with AnyKernel3; verify the ZIP targets `miatoll`.
5. Test on at least one device (see [`docs/DEVICES.md`](DEVICES.md)) and confirm Wi-Fi, BT,
   camera, fingerprint, audio, charging and deep sleep.
6. Add a [`CHANGELOG.md`](../CHANGELOG.md) entry and tag the commit.
7. Upload the ZIP + provenance file to the GitHub Release.

Contributions to any of this follow [`../CONTRIBUTING.md`](../CONTRIBUTING.md).
