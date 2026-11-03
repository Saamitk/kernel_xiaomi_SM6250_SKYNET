# Building SKYNET

The complete `4.14.357-openela` source tree lives at the repository **root**. Build out-of-tree
into `out/` (gitignored). See [`docs/UPSTREAM.md`](UPSTREAM.md) for the pin and
[`docs/RELEASING.md`](RELEASING.md) for turning a build into a flashable ZIP.

> These are the standard Clang/LLD commands for this 4.14 Qualcomm vendor tree. Toolchain versions
> vary — start with `--dry-run`, and treat the first real build as a toolchain compatibility test.
> No binary produced by this repository has been validated on hardware yet.

## 1. Host requirements

- Linux x86_64 (Ubuntu 22.04+ / Debian 12+), ~25 GB free disk, 8 GB RAM (16 GB+ with LTO).
- `git`, `make`, `bc`, `bison`, `flex`, `libssl-dev`, `libelf-dev`, `cpio`, `python3`, `zip`.
- Clang + LLD + LLVM tools. The defconfig enables `CONFIG_LTO_CLANG=y`, `CONFIG_THINLTO=y`,
  `CONFIG_SHADOW_CALL_STACK=y` and `CONFIG_LLVM_POLLY=y`, so **GCC-only builds will not work**.
- GNU cross binutils for `aarch64-linux-gnu-` and `arm-linux-gnueabi-` (32-bit compat/vDSO).

```bash
sudo apt-get update
sudo apt-get install -y \
    git make bc bison flex libssl-dev libelf-dev cpio zip python3 ccache \
    gcc g++ \
    gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
    gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi
```

Prefer a pinned prebuilt Clang (Android `clang-r5xx`, Proton/Neutron Clang, ZyC Clang) and pass
its `bin/` directory with `--clang-dir`. For example:

```bash
git clone --depth 1 https://github.com/kdrag0n/proton-clang.git "$HOME/clang"
clang --version | head -n1   # after adding $HOME/clang/bin to PATH
```

## 2. Verify the source

```bash
./scripts/verify-source.sh
```

Offline check that the tree is complete, the Makefile reports `4.14.357-openela`, the Miatoll
defconfig exists, and the pin quoted in `README.md` / `docs/UPSTREAM.md` matches the tooling.

## 3. Build with the wrapper

```bash
./scripts/build.sh --clang-dir "$HOME/clang/bin"
./scripts/build.sh --dry-run                        # print commands, run nothing
./scripts/build.sh --clean --jobs 8                # mrproper + 8-way build
./scripts/build.sh --menuconfig                   # edit .config, then stop
./scripts/build.sh --target Image.gz              # other make targets
./scripts/build.sh --no-polly                    # Clang toolchains without Polly
```

`--no-polly` disables `CONFIG_LLVM_POLLY` after generating `.config`. The pinned defconfig enables
it, which injects `-mllvm -polly-*` flags that prebuilt toolchains such as proton-clang reject
(`Unknown command line argument '-polly-loopfusion-greedy=1'`). CI sets this by default.

Defaults: source at the repository root, output `out/`, defconfig
`vendor/xiaomi/miatoll_defconfig`, target `Image.gz-dtb`. Overrides via environment:
`KERNEL_DIR`, `OUT_DIR`, `DEFCONFIG`, `TARGET`, `JOBS`, `CLANG_DIR`, `CROSS_COMPILE`,
`CROSS_COMPILE_COMPAT`, `CLANG_TRIPLE`.

## 4. Manual equivalent

From the repository root, with the Clang `bin/` directory on `PATH`:

```bash
ARGS="O=$(pwd)/out ARCH=arm64 \
      HOSTCC=gcc HOSTCXX=g++ HOSTLD=ld \
      CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
      OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
      CLANG_TRIPLE=aarch64-linux-gnu- \
      CROSS_COMPILE=aarch64-linux-gnu- \
      CROSS_COMPILE_ARM32=arm-linux-gnueabi-"

make $ARGS vendor/xiaomi/miatoll_defconfig
make $ARGS olddefconfig
make -j"$(nproc)" $ARGS Image.gz-dtb
```

`olddefconfig` answers new Kconfig prompts with defaults, keeping the build deterministic.
`scripts/` in this repository contains the kernel's own kconfig helpers **and** the SKYNET helper
scripts; their filenames do not clash.

## 5. Outputs

| Path (relative to `out/`) | Meaning |
| --- | --- |
| `arch/arm64/boot/Image.gz-dtb` | Compressed kernel with appended DTB (default target) |
| `arch/arm64/boot/Image.gz` | Compressed kernel without appended DTB |
| `arch/arm64/boot/dtbo.img` | DTBO overlay, if the tree builds one |
| `.config` | Final resolved configuration — attach it to every release |
| `include/config/kernel.release` | Full `kernel.release` string |

## 6. Package a flashable ZIP locally

```bash
./scripts/package-anykernel.sh --name skynet-17-local \
    --out "$PWD/skynet-17-local.zip"
sha256sum skynet-17-local.zip
```

The script clones [AnyKernel3](https://github.com/osm0sis/AnyKernel3), overlays
[`anykernel3/anykernel.sh`](../anykernel3/anykernel.sh), drops in the built images and writes
`skynet-build.prop`. It never commits the ZIP. For CI-built ZIPs see
[`docs/RELEASING.md`](RELEASING.md).

## 7. Changing the configuration

```bash
./scripts/build.sh --menuconfig
# or: ./scripts/config --file out/.config -e SOME_SYMBOL
make O=out ARCH=arm64 savedefconfig
diff -u arch/arm64/configs/vendor/xiaomi/miatoll_defconfig out/defconfig
```

Review the diff, commit only the intended delta, run `olddefconfig` afterwards and explain every
symbol in the commit message.

## 8. Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| `unrecognized command-line option` / LTO link failure | Clang and LLD versions do not match; use one prebuilt toolchain via `--clang-dir`. |
| `ld: unknown option: --thinlto` | `LD=ld.lld` missing; ensure `ld.lld` is on `PATH`. |
| Missing `arm-linux-gnueabi-` tools | Install 32-bit ARM cross binutils; the compat vDSO needs them. |
| `clang: Unknown command line argument '-polly-...'` | Polly unavailable in your Clang; use `./scripts/build.sh --no-polly` (CI does this by default). |
| `scripts/config: not found` | Run the command from the repository root. |
| Stale `.config` after changing defconfig | `./scripts/build.sh --clean`, then regenerate. |
| `uname -r` ignores the new `CONFIG_LOCALVERSION` | Some vendor trees hardcode the suffix in `scripts/setlocalversion` and `init/version.c`; check both before trusting the defconfig. |
| `package-anykernel.sh`: "no kernel image found" | Build `Image.gz-dtb` first; check `out/arch/arm64/boot/`. |
| Build succeeds but device bootloops | Vendor/firmware mismatch or wrong AnyKernel3 block; see [`docs/DEVICES.md`](DEVICES.md). |

## 9. Clean up

```bash
./scripts/build.sh --clean     # mrproper inside out/
rm -rf out                     # full rebuild from scratch
```
