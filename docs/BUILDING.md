# Building SKYNET

This guide builds the pinned `4.14.357-openela` Miatoll kernel from source. The Linux tree lives
in an ignored `kernel/` directory created by
[`scripts/sync-source.sh`](../scripts/sync-source.sh); see
[`docs/UPSTREAM.md`](UPSTREAM.md) for the pin policy.

> The commands below are the standard Clang/LLD flow for this 4.14 Qualcomm vendor tree. Toolchain
> versions vary — always start with `--dry-run`, and treat your first build as a toolchain
> compatibility test. No binary produced by this repository has been validated on hardware yet.

## 1. Host requirements

- Linux x86_64 (Ubuntu 22.04+ / Debian 12+ or equivalent), ~25 GB free disk, 8 GB RAM
  (16 GB+ recommended with LTO).
- `git`, `make`, `bc`, `bison`, `flex`, `libssl-dev`, `libelf-dev`, `cpio`, `python3`.
- Clang + LLD + LLVM tools. The pinned defconfig enables `CONFIG_LTO_CLANG=y`,
  `CONFIG_THINLTO=y` and `CONFIG_SHADOW_CALL_STACK=y`, so **GCC-only builds will not work**.
- GNU cross binutils for `aarch64-linux-gnu-` and `arm-linux-gnueabi-` (the 32-bit compat/vDSO
  side of the tree still uses them).

```bash
sudo apt-get update
sudo apt-get install -y \
    git make bc bison flex libssl-dev libelf-dev cpio python3 \
    gcc g++ clang lld llvm \
    gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
    gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi
```

For reproducible results prefer a pinned Android/prebuilt Clang (for example a `clang-r5xx`
build with LLD), a Neutron/Proton Clang, or ZyC Clang. Pass its `bin/` directory with
`--clang-dir`. Verify what you have:

```bash
clang --version | head -n1
ld.lld --version | head -n1
```

## 2. Fetch the source

```bash
./scripts/sync-source.sh                 # fetches the pinned commit into ./kernel
./scripts/sync-source.sh --check        # offline consistency check (used by CI)
```

The script verifies the Makefile reports `4.14.357` + `-openela` and that
`arch/arm64/configs/vendor/xiaomi/miatoll_defconfig` exists. Re-run with `--force` only if you
want to replace an existing `kernel/` checkout.

## 3. Build with the wrapper

```bash
./scripts/build.sh --clang-dir "$HOME/clang/bin"
./scripts/build.sh --dry-run                       # print commands, run nothing
./scripts/build.sh --clean --jobs 8               # mrproper + 8-way build
./scripts/build.sh --menuconfig                  # edit .config, then stop
./scripts/build.sh --target Image.gz-dtb         # other make targets
```

Useful environment overrides: `KERNEL_DIR`, `OUT_DIR`, `DEFCONFIG`, `TARGET`, `JOBS`,
`CLANG_DIR`, `CROSS_COMPILE`, `CROSS_COMPILE_COMPAT`, `CLANG_TRIPLE`.

## 4. Manual equivalent

From the repository root, with the Clang `bin/` directory on `PATH`:

```bash
export ARCH=arm64
mkdir -p out

ARGS="O=$(pwd)/out ARCH=arm64 \
      HOSTCC=gcc HOSTCXX=g++ HOSTLD=ld \
      CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
      OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
      CLANG_TRIPLE=aarch64-linux-gnu- \
      CROSS_COMPILE=aarch64-linux-gnu- \
      CROSS_COMPILE_ARM32=arm-linux-gnueabi-"

cd kernel
make $ARGS vendor/xiaomi/miatoll_defconfig
make $ARGS olddefconfig
make -j"$(nproc)" $ARGS Image.gz
```

`olddefconfig` answers new Kconfig prompts with defaults, which keeps the build deterministic.

## 5. Outputs

| Path (relative to the output dir) | Meaning |
| --- | --- |
| `arch/arm64/boot/Image.gz` | Compressed kernel image |
| `arch/arm64/boot/Image.gz-dtb` / `dtb.img` | Image with appended device tree, if produced |
| `arch/arm64/boot/dtbo.img` | DTBO overlay, when the tree builds one |
| `.config` | The final resolved configuration — attach it to every release |
| `include/generated/` | Generated headers / `compile.h` |

Package a release with [AnyKernel3](https://github.com/osm0sis/AnyKernel3); never commit the
artefacts. See [`docs/BRANCHING.md`](BRANCHING.md) for the release provenance block.

## 6. Changing the configuration

```bash
cd kernel
make $ARGS menuconfig                 # or: ./scripts/config --file out/.config -e SOME_SYMBOL
make $ARGS savedefconfig              # writes out/defconfig
diff -u arch/arm64/configs/vendor/xiaomi/miatoll_defconfig out/defconfig
```

Only commit defconfig changes to the **kernel source** branch (or record them as a documented
patch), never to this tooling repository. Always run `olddefconfig` afterwards and explain the
reason for every symbol in the commit message.

## 7. Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| `unrecognized command-line option` / LTO link failure | Clang and LLD versions do not match; use one prebuilt toolchain via `--clang-dir`. |
| `ld: unknown option: --thinlto` etc. | `LD=ld.lld` missing; ensure `ld.lld` is on `PATH`. |
| Missing `arm-linux-gnueabi-` tools | Install 32-bit ARM cross binutils; the compat vDSO needs them. |
| `CONFIG_LLVM_POLLY` errors | Polly is not available in your Clang; disable it for local builds with `scripts/config`. |
| `scripts/config: not found` | Run the command from the kernel source root, not from `out/`. |
| Stale `.config` after changing defconfig | `make O=out mrproper` (or `./scripts/build.sh --clean`), then regenerate. |
| Build succeeds but device bootloops | Vendor/firmware mismatch; see [`docs/DEVICES.md`](DEVICES.md). |

## 8. Clean up

```bash
./scripts/build.sh --clean        # mrproper inside the out/ tree
rm -rf kernel/out                 # full rebuild from scratch
rm -rf kernel                    # remove the fetched source (re-run sync-source.sh to restore)
```
