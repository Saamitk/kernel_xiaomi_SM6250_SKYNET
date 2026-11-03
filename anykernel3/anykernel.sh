### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers
## SKYNET Kernel 17 — Xiaomi Miatoll (SM6250), clean / vendor-style build.
##
## This file is overlaid onto a checkout of osm0sis/AnyKernel3 by
## scripts/package-anykernel.sh. It deliberately leaves the stock ramdisk
## untouched: this line ships a kernel, not a root solution.
##
## VERIFY THE BLOCK/DEVICE SETTINGS BELOW FOR YOUR ROM BEFORE FLASHING.
## miatoll is an A-only (non-A/B) device family; some ported ROMs differ.

### AnyKernel setup
# global properties
properties() { '
kernel.string=SKYNET Kernel 17 for miatoll by Saamitk
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=curtana
device.name2=joyeuse
device.name3=excalibur
device.name4=gram
device.name5=miatoll
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot;

# SKYNET is a clean kernel: no ramdisk edits, no module injection.

write_boot;
## end boot install
