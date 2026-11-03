# Releasing a flashable ZIP

SKYNET ZIPs are produced by GitHub Actions, never committed to the repository.

## Producing a ZIP

1. **Actions → Build SKYNET kernel (AnyKernel3 ZIP) → Run workflow** (pick the branch to build).
   It also runs automatically on `skynet-17-*` tags and when the workflow/build/packaging files
   change — that first automatic run is what registers it for manual dispatch.
2. Inputs: Clang repo/ref (default `kdrag0n/proton-clang`), make target (default `Image.gz-dtb`),
   `no_polly` (default `true`, required for Clang builds without Polly), and an optional
   `release_tag`.
3. The workflow installs dependencies, fetches the pinned Clang, verifies the in-tree source with
   [`scripts/verify-source.sh`](../scripts/verify-source.sh), builds with
   [`scripts/build.sh`](../scripts/build.sh), then calls
   [`scripts/package-anykernel.sh`](../scripts/package-anykernel.sh).
4. Download the `skynet-kernel-zip` artifact: `skynet-17-<date>-<run>.zip` plus its `.sha256`.
   Supplying `release_tag` also publishes both files to a GitHub Release.

### Promote an existing artifact (no rebuild)

A manual build already produced a ZIP; publishing it as a Release should not cost another
20-minute build. From the default branch:

```bash
gh workflow run publish-release.yml --ref main \
  -f run_id=<successful-build-run-id> -f tag=skynet-17-r1
```

The workflow downloads `skynet-kernel-zip` from that run, verifies the ZIP against its `.sha256`
and with `unzip -t`, then creates a **pre-release** with an explicit "UNTESTED" warning. Both
files become permanent release assets. Releases are never committed to the repository.

Typical runtime is 25–45 minutes. The first run is a **toolchain compatibility test** — the
pinned defconfig enables `CONFIG_LTO_CLANG`, `CONFIG_THINLTO`, `CONFIG_SHADOW_CALL_STACK` and
`CONFIG_LLVM_POLLY`, so an incompatible Clang/LLD will fail early. See
[`docs/BUILDING.md`](BUILDING.md) for troubleshooting and local packaging.

## ZIP contents

| Path | Meaning |
| --- | --- |
| `META-INF/com/google/android/update-binary`, `updater-script` | AnyKernel3 installer |
| `tools/ak3-core.sh` and helpers | AnyKernel3 framework (fetched at packaging time) |
| `anykernel.sh` | SKYNET device/block configuration from `anykernel3/` |
| `Image.gz-dtb` / `Image.gz` | Compressed kernel image (appended DTB when available) |
| `dtbo.img` | Included only if the build produced one |
| `skynet-build.prop` | Build provenance |

`skynet-build.prop` records `kernel.release`, the defconfig and `CONFIG_LOCALVERSION`, the source
commit and pin, the images included and a UTC build timestamp. Attach `out/.config` and the
Clang/LLD version strings to the release notes as well.

## Release checklist

1. [`CHANGELOG.md`](../CHANGELOG.md) entry under the `17` line.
2. Tag `skynet-17-r<N>`; see [`docs/BRANCHING.md`](BRANCHING.md).
3. Upload the ZIP, `.sha256`, `out/.config` and the provenance file.
4. State exactly which device/codename and ROM the ZIP was tested on.

## Flashing

1. Unlock the bootloader and install a working custom recovery.
2. **Back up stock `boot` and `dtbo`** and keep the images off the phone.
3. Verify the ZIP is for `miatoll` and that `anykernel.sh`'s `BLOCK`/slot settings match your ROM.
4. Flash in recovery, wipe cache/dalvik if your recovery requires it, reboot.
5. Check `uname -r` reads `4.14.357-openela-SKYNET`. If it ends in `-kinesis-omega-bpf`, the
   ZIP was built before the SKYNET localversion change — do not publish it as a new release.

If Wi-Fi, camera, fingerprint or charging break, suspect a vendor/firmware mismatch before
changing the config — see [`docs/DEVICES.md`](DEVICES.md). Keep a `fastboot` path back to the
stock images. A kernel flash can boot-loop or brick a device; you are responsible for your own
hardware.
