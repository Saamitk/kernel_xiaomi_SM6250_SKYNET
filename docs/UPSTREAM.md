# Upstream source and the pinned commit

## The source is in-tree

Unlike the original scaffold, this repository now contains the **complete Linux kernel source
tree at its root**. The original import placed it in a `kernel/` subfolder;
`.github/workflows/flatten-source.yml` moved it to the root so the layout matches a normal kernel
source repository (`Makefile`, `Kconfig`, `arch/`, `drivers/`, `fs/`, `techpack/`, … at the top).

> The `kernel/` directory that now exists at the root is the **kernel core source directory**, not
> a wrapper folder. Do not move the tree back into a subfolder.

## The pin

| Field | Value |
| --- | --- |
| Repository | [`AzyrRuthless/kernel_xiaomi_sm6250`](https://github.com/AzyrRuthless/kernel_xiaomi_sm6250) |
| Clone URL | `https://github.com/AzyrRuthless/kernel_xiaomi_sm6250.git` |
| Branch | `16` (default) |
| Commit | `4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183` |
| Commit subject | `miatoll_defconfig: reflect changes` |
| Kernel | `4.14.357-openela` (`VERSION=4`, `PATCHLEVEL=14`, `SUBLEVEL=357`, `EXTRAVERSION=-openela`) |
| `CONFIG_LOCALVERSION` | `-kinesis-omega-bpf` (upstream; SKYNET overrides it to `-SKYNET`) |
| Defconfig | `arch/arm64/configs/vendor/xiaomi/miatoll_defconfig` |
| License | `SPDX-License-Identifier: GPL-2.0` (kernel source, see `COPYING`) |

The pinned reference tree has **72,779 files**. SKYNET's own defconfig changes only the
`CONFIG_LOCALVERSION` branding; all other options below are inherited unchanged from the pin. The first import committed 72,722 because nested
`.gitignore` files filtered 57 dotfiles (`.elts/*`, `.gitattributes`,
`.get_maintainer.ignore`, `.cocciconfig`, `fs/exfat/.github/workflows/c-cpp.yml`, some ACPI tool
sources and firmware `.i` files). The flatten workflow re-fetched the pin and force-added those
files, so the in-tree copy is complete.

The upstream repository was **archived read-only on 2026-05-27**, so the pin will not move on its
own. Other upstream refs, kept for reference only:

- branch `16-5.4` — experimental 5.4 line (not used by the `17` line);
- tags `kinesis-r5.2`, `kinesis-r5.0`, `kinesis-r4.7`, `kinesis-r4.5`.

The reference tree is itself a fork of
[`clarencekopitiam/kernel_xiaomi_sm6250`](https://github.com/clarencekopitiam/kernel_xiaomi_sm6250),
ultimately derived from Xiaomi/Qualcomm `msm-4.14` sources with OpenELA LTS updates. See
[`docs/LICENSE-NOTICE.md`](LICENSE-NOTICE.md) for licensing.

## Verifying the checkout

`./scripts/verify-source.sh` is fully offline. It:

- checks that [`README.md`](../README.md) and this document quote the same pin and
  `4.14.357`;
- detects the source root (root, or `kernel/` before flattening);
- parses the Makefile for `4.14.357` + `-openela`;
- confirms `arch/arm64/configs/vendor/xiaomi/miatoll_defconfig` exists;
- reports the tracked-file count.

CI (`Validate`) runs it on every push and pull request.

## Re-importing or bumping the pin

The original `.github/workflows/Import.yml` is retained for history but **must not be re-run** —
it targets a `kernel/` subfolder. To re-sync or bump the pin:

1. Pick a new commit from the reference repo, a maintained fork, or your own kernel branch.
2. In one dedicated commit, update `PINNED_COMMIT` in `scripts/verify-source.sh`, the pin in
   `README.md` and the table above, plus `PIN` in `flatten-source.yml` and `build-kernel.yml`
   provenance where relevant. Update `EXPECTED_VERSION` / `EXPECTED_EXTRAVERSION` if the version
   changed.
3. Run `./scripts/verify-source.sh`, then re-run `flatten-source.yml` (it re-fetches the pin into
   the root and is idempotent once the layout is flat).
4. Do a clean build and record the toolchain requirements in
   [`CHANGELOG.md`](../CHANGELOG.md).

Never point the pin at a moving branch tip — builds must be reproducible.

## Sign-off

The upstream repository requires signed-off commits. Follow
[`CONTRIBUTING.md`](../CONTRIBUTING.md) and use `git commit -s` for any change you intend to send
upstream.
