# Supported devices

`miatoll` is the **unified** board name for four Xiaomi/POCO phones built on the Qualcomm SM6250
("atoll", Snapdragon 720G class) platform. One kernel image, built from
`vendor/xiaomi/miatoll_defconfig`, targets all of them.

| Retail device | Codename | Variant notes |
| --- | --- | --- |
| Redmi Note 9S / Redmi Note 9 Pro (India) | `curtana` | Global 9S / Indian 9 Pro |
| Redmi Note 9 Pro (Global) | `joyeuse` | Global 9 Pro |
| Redmi Note 9 Pro Max (India) | `excalibur` | Indian Pro Max |
| POCO M2 Pro | `gram` | Indian POCO M2 Pro |
| Unified ROM builds | `miatoll` | What custom ROMs usually report |

## Identifying a device

```bash
adb shell getprop ro.product.device
adb shell getprop ro.boot.hardware
adb shell getprop ro.build.product
adb shell uname -r
```

Custom ROMs commonly report `miatoll` for `ro.product.device` regardless of the underlying
codename; `ro.boot.hardware` and the bootloader's DTB selection are more reliable. Record all of
them in bug reports.

## Device tree and firmware

- Board DTS/DTSI files live under the kernel's `arch/arm64/boot/dts/` tree (Qualcomm
  `atoll`/`sdmmagpie` family).
- The bootloader selects a DTB by hardware ID; appended-DTB and DTBO handling depends on the ROM
  and Android version. Do not mix a kernel with vendor blobs or firmware from a different ROM
  generation.
- A `4.14` non-GKI vendor kernel is tied to the vendor partition it was built for. If Wi-Fi,
  camera or fingerprint break after flashing, check vendor/firmware matching before changing the
  kernel config.

## Before flashing anything

1. Unlock the bootloader and install a working custom recovery.
2. Back up the stock `boot` and `dtbo` partitions and keep them off the phone.
3. Verify the ZIP is built for `miatoll` (not `curtana`-only or another board).
4. Test on one device first; keep a way to restore the stock images with `fastboot`.

See [`docs/BUILDING.md`](BUILDING.md) for how images are produced, and
[`../README.md`](../README.md) for the flashing disclaimer.
