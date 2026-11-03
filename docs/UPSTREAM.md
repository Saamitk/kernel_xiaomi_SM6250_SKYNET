# Upstream source and the pinned commit

## Why the kernel source is not in this repository

The reference tree is a complete 4.14 Qualcomm vendor kernel: roughly **1.3 GB**, ~60,000 files
and ~810,000 commits of history. Vendoring it here would make normal review, clones and CI
impractical. Instead, [`scripts/sync-source.sh`](../scripts/sync-source.sh) performs a shallow
fetch of one exact commit into `kernel/`, which is gitignored. That gives reproducible builds
without duplicating the Linux tree.

## The pin

| Field | Value |
| --- | --- |
| Repository | [`AzyrRuthless/kernel_xiaomi_sm6250`](https://github.com/AzyrRuthless/kernel_xiaomi_sm6250) |
| Clone URL | `https://github.com/AzyrRuthless/kernel_xiaomi_sm6250.git` |
| Branch | `16` (default) |
| Commit | `4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183` |
| Commit subject | `miatoll_defconfig: reflect changes` |
| Kernel | `4.14.357-openela` (`VERSION=4`, `PATCHLEVEL=14`, `SUBLEVEL=357`, `EXTRAVERSION=-openela`) |
| `CONFIG_LOCALVERSION` | `-kinesis-omega-bpf` |
| Defconfig | `arch/arm64/configs/vendor/xiaomi/miatoll_defconfig` |
| License | `SPDX-License-Identifier: GPL-2.0` (kernel source) |

The upstream repository was **archived read-only on 2026-05-27**, so the pin will not move on its
own. Other upstream refs, kept here for reference only:

- branch `16-5.4` — experimental 5.4 line (not used by the `17` line);
- tags `kinesis-r5.2`, `kinesis-r5.0`, `kinesis-r4.7`, `kinesis-r4.5`.

The reference tree is itself a fork of
[`clarencekopitiam/kernel_xiaomi_sm6250`](https://github.com/clarencekopitiam/kernel_xiaomi_sm6250),
and ultimately derives from Xiaomi/Qualcomm `msm-4.14` sources with OpenELA LTS updates. See
[`docs/LICENSE-NOTICE.md`](LICENSE-NOTICE.md) for the licensing implications.

## Verifying a checkout

`sync-source.sh` checks out the pin and refuses to continue unless:

- `git rev-parse HEAD` equals the pin;
- the Makefile reports `4.14.357` and `-openela`;
- `arch/arm64/configs/vendor/xiaomi/miatoll_defconfig` exists.

Run `./scripts/sync-source.sh --check` for an offline check that the pin quoted in this document,
in [`../README.md`](../README.md) and in the script all agree. CI runs exactly that command.

## Bumping the pin

1. Pick a new commit (from the reference repo, a maintained fork, or your own kernel branch).
2. In one dedicated commit, update `PINNED_COMMIT` in `scripts/sync-source.sh`, the pin in
   `README.md`, and the table above. Update `EXPECTED_VERSION` / `EXPECTED_EXTRAVERSION` if the
   kernel version changed.
3. Run `./scripts/sync-source.sh --check`, then `./scripts/sync-source.sh --force` and a clean
   build.
4. Record the reason for the bump and the new toolchain requirements in
   [`../CHANGELOG.md`](../CHANGELOG.md).

If the new source lives at a different URL or branch, update `UPSTREAM_URL` / `UPSTREAM_BRANCH`
in the script too. Never point the pin at a moving branch tip — builds must be reproducible.

## Sign-off

The upstream repository requires signed-off commits. Follow
[`../CONTRIBUTING.md`](../CONTRIBUTING.md) and use `git commit -s` for any change you intend to
send upstream.
