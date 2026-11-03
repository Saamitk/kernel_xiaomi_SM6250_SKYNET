# Changelog

All notable changes to the SKYNET kernel project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); see
[`docs/BRANCHING.md`](docs/BRANCHING.md) for tags and releases.

## [Unreleased] — `17` line

### Added

- Complete `4.14.357-openela` kernel source tree committed in this repository, **at the root**
  (72,779 files from pin `4afc6f0769f0f3b2b10d50d3fa02f0ba7c89a183`).
- `.github/workflows/flatten-source.yml`: one-shot, idempotent migration from the original
  `kernel/` subfolder to the root; re-imports the pin so the 57 dotfiles filtered by nested
  `.gitignore` rules are restored.
- `.github/workflows/build-kernel.yml`: Clang/LLD build → AnyKernel3 ZIP artifact → optional
  GitHub Release, with `kernel.release`, `.config` and toolchain provenance.
- [`anykernel3/anykernel.sh`](anykernel3/anykernel.sh): device checks for `curtana`, `joyeuse`,
  `excalibur`, `gram` and `miatoll`; clean kernel, no ramdisk edits.
- `scripts/package-anykernel.sh` and `scripts/verify-source.sh`; `scripts/sync-source.sh` removed
  (the source is now in-tree).
- [`docs/RELEASING.md`](docs/RELEASING.md): ZIP contents, provenance and flashing checklist.
- Updated README, build/branching/upstream/license docs, CI, `.gitignore` (kernel rules plus
  SKYNET exceptions for `.github/`, `.elts/` and build outputs).

### Changed

- `scripts/build.sh` auto-detects the source root (root or legacy `kernel/`) and defaults to
  `Image.gz-dtb`; `Validate` CI now lints only the SKYNET helper scripts.
- CI disables `CONFIG_LLVM_POLLY` by default (`--no-polly`): the pinned defconfig's Polly flags
  are rejected by prebuilt Clang toolchains without Polly.
- `docs/LICENSE-NOTICE.md`: with the GPL-2.0 tree in-tree, `COPYING` is the primary license for
  kernel code and GPL-3.0 `LICENSE` covers SKYNET-authored files.

### Notes

- The `17` line stays **clean / stock-like**: no KernelSU, SUSFS or other root/hiding patches.
- No flashable ZIP is committed; none has been validated on hardware yet. Add a
  `skynet-17-r1` entry with build provenance when the first ZIP ships.

## [0.1.0] — scaffold

- Initial README, device matrix, build/sync tooling, docs, CI and issue/PR templates.

[Unreleased]: https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/commits/main
[0.1.0]: https://github.com/Saamitk/kernel_xiaomi_SM6250_SKYNET/pull/1
