# SKYNET Kernel — Xiaomi Miatoll (SM6250)

[![Validate](https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/actions/workflows/validate.yml/badge.svg)](https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/actions/workflows/validate.yml)
[![Build kernel (AnyKernel3 ZIP)](https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/actions/workflows/build-kernel.yml/badge.svg)](https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/actions/workflows/build-kernel.yml)
![Kernel](https://img.shields.io/badge/kernel-4.14.357--openela-blue)
![Platform](https://img.shields.io/badge/platform-SM6250%20%22atoll%22-green)
![Line](https://img.shields.io/badge/line-17-purple)

**SKYNET** is a clean, vendor-style Android kernel for the **Xiaomi Miatoll** family
(Redmi Note 9S / 9 Pro / 9 Pro Max and POCO M2 Pro). This repository holds the **complete kernel
source tree at the root** plus the SKYNET documentation, build tooling, AnyKernel3 template and
CI workflows for the **"17" line**.

> **Status:** full `4.14.357-openela` source in-tree. Clean / stock-like configuration — no
> KernelSU, SUSFS or other root/hiding integrations. Flashable AnyKernel3 ZIPs are built by
> GitHub Actions; no ZIP is committed and no build has been validated on hardware yet.

## Where the kernel source lives

The tree sits **directly in the repository root**, like any normal kernel source repository:

```
arch/   block/   certs/   crypto/   drivers/   firmware/   fs/   include/   init/
ipc/    kernel/  lib/     mm/       net/       samples/    scripts/       security/
sound/  techpack/ tools/   usr/      virt/      Documentation/
Makefile  Kconfig  Kbuild  COPYING  CREDITS  MAINTAINERS  README  ...
```

> **Important:** the `kernel/` directory at the root is the **Linux kernel core source
> directory**, not a folder containing the whole tree. The original import placed everything in
> a `kernel/` subfolder; `.github/workflows/flatten-source.yml` moved it to the root. Only
> SKYNET-owned files live in `.github/`, `docs/`, `scripts/`, `anykernel3/` and a handful of root
> docs.

The flatten workflow also re-fetched the pinned tree so that the 57 dotfiles (`.elts/`,
`.gitattributes`, `.get_maintainer.ignore`, …) dropped by the original import's nested
`.gitignore` rules are present again.

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
| Upstream reference | [`AzyrRuthless/kernel_xiaomi_sm6250`](https://github.com/AzyrRuthless/kernel_xiaomi_sm6250) (archived read-only 2026-05-27) |
| Reference branch | `16` (default); `16-5.4` is an experimental 5.4 line |
| Pinned commit | `4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183` — *"miatoll_defconfig: reflect changes"* |
| Kernel version | `4.14.357-openela` (OpenELA LTS), `SPDX-License-Identifier: GPL-2.0` |
| Defconfig | `arch/arm64/configs/vendor/xiaomi/miatoll_defconfig` |
| `CONFIG_LOCALVERSION` | `-kinesis-omega-bpf` |
| Notable config | `CONFIG_LTO_CLANG=y`, `CONFIG_THINLTO=y`, `CONFIG_SHADOW_CALL_STACK=y`, `CONFIG_BPF_SYSCALL=y`, `CONFIG_CGROUP_BPF=y` |

The Clang LTO/ThinLTO and shadow-call-stack options mean a **Clang + LLD** toolchain is required;
GCC-only builds will not work. See [`docs/BUILDING.md`](docs/BUILDING.md).

## Repository layout

| Path | Purpose |
| --- | --- |
| `Makefile`, `arch/`, `drivers/`, `fs/`, `techpack/`, … | The complete kernel source tree |
| `README.md` | Project overview (this file) |
| [`CHANGELOG.md`](CHANGELOG.md) | Line history and release notes |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Contribution, commit and testing rules |
| [`docs/`](docs/) | Building, devices, branching, upstream, licensing, releasing |
| `scripts/build.sh` | Reproducible defconfig + Clang build wrapper |
| `scripts/verify-source.sh` | Offline source + documentation pin verification |
| `scripts/package-anykernel.sh` | Assemble the flashable AnyKernel3 ZIP |
| `scripts/check-links.py` | CI check for broken relative Markdown links |
| [`anykernel3/anykernel.sh`](anykernel3/anykernel.sh) | AnyKernel3 device/block configuration |
| `.github/workflows/flatten-source.yml` | One-shot migration of the tree to the root |
| `.github/workflows/build-kernel.yml` | Build kernel and publish the AnyKernel3 ZIP |
| `.github/workflows/validate.yml` | Docs/scripts CI |

> The original `.github/workflows/Import.yml` is kept for history. It imports into a `kernel/`
> subfolder and **should not be re-run** now that the tree is at the root.

## Quick start

Requirements: Linux x86_64, `git`, `make`, a pinned Clang/LLD toolchain, `aarch64-linux-gnu-*`
and `arm-linux-gnueabi-*` binutils, `bc bison flex libssl-dev libelf-dev cpio zip python3`, and
~25 GB of free disk space.

```bash
git clone https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET.git
cd kernel_xiaomi_SM6250_SKYNET

./scripts/verify-source.sh                          # offline source + pin check
./scripts/build.sh --clang-dir "$HOME/clang/bin" --dry-run
./scripts/build.sh --clang-dir "$HOME/clang/bin"    # -> out/arch/arm64/boot/Image.gz-dtb
```

Full details are in [`docs/BUILDING.md`](docs/BUILDING.md).

## GitHub Actions

| Workflow | Trigger | What it does |
| --- | --- | --- |
| Flatten kernel source to repository root | push of that workflow / manual | One-shot: moves the tree out of `kernel/` into the root (already done, idempotent) |
| Build SKYNET kernel (AnyKernel3 ZIP) | manual dispatch, edits to its workflow/build/packaging files, `skynet-17-*` tags | Builds the kernel, packages an AnyKernel3 ZIP, uploads the artifact, optionally publishes a Release |
| Publish SKYNET ZIP release | manual dispatch | Promotes an existing build artifact into a GitHub Release without rebuilding |
| Validate | push / PR | Shell syntax, ShellCheck, source/pin verification, Markdown links |

**To get a flashable ZIP:** Actions → *Build SKYNET kernel (AnyKernel3 ZIP)* → *Run workflow* →
download the `skynet-kernel-zip` artifact. To make it a permanent Release, run
*Publish SKYNET ZIP release* with that run's ID. See [`docs/RELEASING.md`](docs/RELEASING.md).

## The `17` branch

`17` is the next-generation line after the reference's `16` branch — a **branch label**, not a
Linux version (the kernel stays 4.14.357). This work was prepared on the Arena working branch and
proposed as a PR into `main`; the session's branch name is fixed, so the `17` branch itself must be
created by the maintainer after the PR merges:

```bash
git fetch origin
git switch -c 17 origin/main
git push -u origin 17

# Optional: make 17 the default branch
gh api -X PATCH repos/Saamitk/kernel_xiaomi_SM6250_SKYNET -f default_branch=17
```

See [`docs/BRANCHING.md`](docs/BRANCHING.md) for the full policy.

## Flashing and testing

Back up stock `boot`/`dtbo`, use an unlocked bootloader and custom recovery, verify the
AnyKernel3 `BLOCK`/slot settings for your ROM, and test on **one** device first. A 4.14 vendor
kernel must match the ROM's vendor blobs and firmware. Flashing a kernel can boot-loop or brick a
device — you are responsible for your own hardware. Full checklist:
[`docs/RELEASING.md`](docs/RELEASING.md).

## Contributing

Read [`CONTRIBUTING.md`](CONTRIBUTING.md). In short: signed-off commits (`git commit -s`), no
generated images/ZIPs/`out/` committed, config changes explained with the device tested.

## License and credits

- The kernel source at the root is **GPL-2.0** (`COPYING`, SPDX headers).
- SKYNET-authored docs, scripts and CI in [`LICENSE`](LICENSE) are **GPL-3.0**.
- See [`docs/LICENSE-NOTICE.md`](docs/LICENSE-NOTICE.md) before relicensing.
- Credits: the [reference tree](https://github.com/AzyrRuthless/kernel_xiaomi_sm6250) and its
  upstream chain (Xiaomi, Qualcomm/Code Aurora, OpenELA, Linux kernel contributors),
  [AnyKernel3](https://github.com/osm0sis/AnyKernel3), and the Miatoll community.

**Disclaimer:** Independent, unofficial project; not affiliated with Xiaomi, POCO, Qualcomm or
upstream maintainers. Provided as-is, without warranty.
