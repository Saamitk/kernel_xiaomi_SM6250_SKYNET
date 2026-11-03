# AnyKernel3 template

This folder holds SKYNET's `anykernel.sh` configuration only. The complete AnyKernel3 framework
(`META-INF/`, `tools/`, `patch/`, `ramdisk/`) is fetched from
[`osm0sis/AnyKernel3`](https://github.com/osm0sis/AnyKernel3) at packaging time by
[`scripts/package-anykernel.sh`](../scripts/package-anykernel.sh) and is **not** stored in this
repository — that keeps the license boundaries clear and avoids bundling third-party binaries.

`anykernel.sh` sets:

- `kernel.string` = `SKYNET Kernel 17 for miatoll by Saamitk`
- `do.devicecheck=1` for `curtana`, `joyeuse`, `excalibur`, `gram` and unified `miatoll`
- `BLOCK=boot`, `IS_SLOT_DEVICE=0` (A-only), `do.modules=0`, `do.systemless=1`
- no ramdisk modifications — a clean kernel image only

The built `Image.gz-dtb` (and `dtbo.img` when available) plus a `skynet-build.prop` provenance
file are dropped into the ZIP root. See [`docs/RELEASING.md`](../docs/RELEASING.md) for the full
ZIP contents and the flashing checklist.

**Before flashing:** confirm `BLOCK`/slot settings against your exact ROM, back up stock `boot`
and `dtbo`, and test on one device. A CI-built ZIP has not been validated on hardware.
