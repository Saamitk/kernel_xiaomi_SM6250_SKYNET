# Changelog

All notable changes to the SKYNET kernel project are documented here. This file follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project's own
[branch/tag policy](docs/BRANCHING.md).

## [Unreleased] — `17` line

### Added

- Project README with device matrix, base provenance, quick start and disclaimer.
- `scripts/sync-source.sh`: fetches the exact pinned `4.14.357-openela` reference tree into an
  ignored `kernel/` directory, verifies the kernel version and the Miatoll defconfig, and offers a
  `--check` mode for CI.
- `scripts/build.sh`: reproducible `vendor/xiaomi/miatoll_defconfig` + Clang/LLD build wrapper with
  `--dry-run`, `--clean`, `--menuconfig`, `--jobs` and toolchain overrides.
- `scripts/check-links.py`: validates relative Markdown links.
- Documentation: [`docs/BUILDING.md`](docs/BUILDING.md), [`docs/DEVICES.md`](docs/DEVICES.md),
  [`docs/BRANCHING.md`](docs/BRANCHING.md), [`docs/UPSTREAM.md`](docs/UPSTREAM.md) and
  [`docs/LICENSE-NOTICE.md`](docs/LICENSE-NOTICE.md).
- [`CONTRIBUTING.md`](CONTRIBUTING.md), `.gitignore`, a `Validate` CI workflow, issue templates and
  a pull request template.

### Notes

- The `17` line is a **clean / stock-like** base: no KernelSU, SUSFS or other root/hiding patches.
- No kernel source is vendored. The pin is
  `4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183` from the reference's `16` branch.
- No flashable build is released yet. Add a `skynet-17-r1` entry here with build provenance when
  the first ZIP ships.

[Unreleased]: https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/commits/main
