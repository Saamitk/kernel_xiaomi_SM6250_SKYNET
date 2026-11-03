# SKYNET Kernel — Xiaomi Miatoll (SM6250)

[![Validate](https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/actions/workflows/validate.yml/badge.svg)](https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/actions/workflows/validate.yml)
![Kernel](https://img.shields.io/badge/kernel-4.14.357--openela-blue)
![Platform](https://img.shields.io/badge/platform-SM6250%20%22atoll%22-green)
![Line](https://img.shields.io/badge/line-17-purple)
![License](https://img.shields.io/badge/license-GPL--3.0-orange)

**SKYNET** is a clean, vendor-style Android kernel project for the **Xiaomi Miatoll** family
(Redmi Note 9S / 9 Pro / 9 Pro Max and POCO M2 Pro). This repository is the documentation and
build-tooling home of the **"17" line** — the successor generation to the upstream `16` branch.

> **Status:** scaffolding for the `17` line. The tree is deliberately **clean / stock-like**:
> no KernelSU, SUSFS, or other root/hiding integrations. Nothing here is a flashable build yet.

## What is in this repository

The upstream Linux source is **not** copied into this repository. A full 4.14 Qualcomm vendor tree
is roughly 1.3 GB and ~60,000 files, which makes a repository unusable for review and exceeds
normal working limits. Instead:

- [`scripts/sync-source.sh`](scripts/sync-source.sh) fetches one **exact, pinned commit** of the
  reference kernel into an ignored `kernel/` directory;
- [`scripts/build.sh`](scripts/build.sh) wraps the defconfig + Clang build with reproducible flags;
- [`docs/`](docs/) documents devices, toolchains, branching, upstream sync and licensing.

Everything committed here is small, human-reviewable text: docs and scripts only.

## Supported devices (unified `miatoll`)

| Device | Codename | Notes |
| --- | --- | --- |
| Redmi Note 9S / Redmi Note 9 Pro (India) | `curtana` | unified `miatoll` target |
| Redmi Note 9 Pro (Global) | `joyeuse` | unified `miatoll` target |
| Redmi Note 9 Pro Max (India) | `excalibur` | unified `miatoll` target |
| POCO M2 Pro | `gram` | unified `miatoll` target |
| Any unified build | `miatoll` | single kernel image for all four |

Platform: Qualcomm **SM6250 / "atoll"**, 64-bit ARM (`ARCH=arm64`), Snapdragon 720G class.
See [`docs/DEVICES.md`](docs/DEVICES.md).

## Base and provenance

| Item | Value |
| --- | --- |
| Reference tree | [`AzyrRuthless/kernel_xiaomi_sm6250`](https://github.com/AzyrRuthless/kernel_xiaomi_sm6250) (archived read-only 2026-05-27) |
| Reference branch | `16` (default); `16-5.4` exists as an experimental 5.4 line |
| Pinned commit | `4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183` — *"miatoll_defconfig: reflect changes"* |
| Kernel version | `4.14.357-openela` (OpenELA LTS), `SPDX-License-Identifier: GPL-2.0` |
| Defconfig | `arch/arm64/configs/vendor/xiaomi/miatoll_defconfig` |
| `CONFIG_LOCALVERSION` | `-kinesis-omega-bpf` |
| Notable config | `CONFIG_LTO_CLANG=y`, `CONFIG_THINLTO=y`, `CONFIG_SHADOW_CALL_STACK=y`, `CONFIG_BPF_SYSCALL=y`, `CONFIG_CGROUP_BPF=y` |

Because the defconfig enables Clang LTO/ThinLTO and shadow call stack, a **Clang + LLD**
toolchain (not plain GCC) is required. See [`docs/BUILDING.md`](docs/BUILDING.md).

## Repository layout

| Path | Purpose |
| --- | --- |
| `README.md` | Project overview (this file) |
| [`CHANGELOG.md`](CHANGELOG.md) | Line history and release notes |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Contribution, commit and testing rules |
| [`docs/BUILDING.md`](docs/BUILDING.md) | Toolchain setup, build commands, troubleshooting |
| [`docs/DEVICES.md`](docs/DEVICES.md) | Device/codename matrix and verification |
| [`docs/BRANCHING.md`](docs/BRANCHING.md) | The `17` line, release/tag scheme, how to create the branch |
| [`docs/UPSTREAM.md`](docs/UPSTREAM.md) | Pinned source policy, license notes, how to bump the pin |
| [`docs/LICENSE-NOTICE.md`](docs/LICENSE-NOTICE.md) | GPL-3.0 vs GPL-2.0 licensing notes |
| `scripts/sync-source.sh` | Fetch the pinned kernel source into ignored `kernel/` |
| `scripts/build.sh` | Reproducible defconfig + Clang build wrapper |
| `scripts/check-links.py` | CI check for broken relative Markdown links |
| `.github/workflows/validate.yml` | CI: shell syntax + docs/pin consistency checks |
| `.github/ISSUE_TEMPLATE/` | Bug report and feature request templates |
| `LICENSE` | GPL-3.0 for the docs/scripts in this repository |

## Quick start

Requirements: Linux x86_64, `git`, `make`, `clang`/`llvm` with LLD, `aarch64-linux-gnu-*` and
`arm-linux-gnueabi-*` binutils, `bc bison flex libssl-dev libelf-dev cpio python3`, and ~25 GB of
free disk space.

```bash
git clone https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET.git
cd kernel_xiaomi_SM6250_SKYNET

./scripts/sync-source.sh                            # -> ./kernel (gitignored, pinned commit)
./scripts/build.sh --clang-dir "$HOME/clang/bin"    # -> ./kernel/out/arch/arm64/boot/Image.gz
```

`./scripts/build.sh --dry-run` prints the exact `make` commands without executing them.
Full details, including manual commands and toolchain notes, are in
[`docs/BUILDING.md`](docs/BUILDING.md).

## The `17` branch

`17` is the next-generation line after the reference's `16` branch — it is a **branch label**,
not a Linux kernel version (the kernel stays 4.14.357). This contribution was prepared on the
Arena working branch `arena/0b00731c-kernel-xiaomi-sm6250-skynet` and proposed as a PR into
`main`; the session's branch name is fixed, so the `17` branch itself must be created by the
maintainer. After the PR is merged:

```bash
git fetch origin
git switch -c 17 origin/main
git push -u origin 17

# Optional: make 17 the default branch
gh api -X PATCH repos/Saamitk/kernel_xiaomi_SM6250_SKYNET -f default_branch=17
```

See [`docs/BRANCHING.md`](docs/BRANCHING.md) for the full policy.

## Flashing and testing

No flashable ZIP is published by this repository yet. When builds are produced, package them with
[AnyKernel3](https://github.com/osm0sis/AnyKernel3) and test on **one** device first. Always keep
a backup of the stock `boot`/`dtbo` images, use an unlocked bootloader, and expect that a
4.14 vendor kernel must match the ROM's vendor blobs and firmware. Flashing a kernel can boot-loop
or brick a device — you are responsible for your own hardware.

## Contributing

Read [`CONTRIBUTING.md`](CONTRIBUTING.md). In short: keep commits small and signed off
(`git commit -s`), never commit the generated `kernel/` or `out/` trees, bump the upstream pin in
a dedicated commit, and document every config change with the reason and the device it was tested on.

## License and credits

- The scripts and documentation in this repository are **GPL-3.0** (see [`LICENSE`](LICENSE)).
- The Linux kernel source fetched by `sync-source.sh` is **GPL-2.0** and keeps its own license;
  see [`docs/LICENSE-NOTICE.md`](docs/LICENSE-NOTICE.md) before changing the repository license.
- Credits: the [reference kernel tree](https://github.com/AzyrRuthless/kernel_xiaomi_sm6250) and
  its upstream chain (Xiaomi, Qualcomm/Code Aurora, OpenELA, Linux kernel contributors), plus the
  Miatoll development community.

**Disclaimer:** This is an independent, unofficial project. It is not affiliated with or endorsed
by Xiaomi, POCO, Qualcomm, or the upstream maintainers. Provided as-is, without warranty.
