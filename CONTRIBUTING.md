# Contributing to SKYNET

The kernel source tree now lives at the repository root. Most contributions will be to that tree;
SKYNET-specific tooling lives in `scripts/`, `docs/`, `anykernel3/` and `.github/`.

## Ground rules

1. **Every commit must be signed off** (`git commit -s`), matching the upstream kernel's
   Developer Certificate of Origin:
   ```
   Signed-off-by: Your Name <you@example.com>
   ```
2. **Do not commit generated artefacts** — `out/`, `Image.gz*`, `*.img`, `*.ko`, `*.zip`, logs,
   `.config` copies or toolchain downloads. `.gitignore` (kernel rules + SKYNET extras) covers
   them.
3. **Never re-run `.github/workflows/Import.yml`** — it would put a second copy of the tree into
   a `kernel/` subfolder. Use `flatten-source.yml` (idempotent) if the layout ever needs repair.
4. **No root/hiding patches in the `17` line by default.** KernelSU, SUSFS and similar
   integrations belong on a separate, clearly named experimental branch.
5. **One logical change per commit**, with an explanation of *why* and the device/codename and
   ROM it was tested on.
6. Keep the upstream pin quoted in `README.md`, `docs/UPSTREAM.md` and
   `scripts/verify-source.sh` in sync; `./scripts/verify-source.sh` enforces this.

## Commit message style

```
arm64: configs: miatoll: enable <symbol>
drivers: <subsystem>: fix <problem>
scripts: allow overriding CROSS_COMPILE_COMPAT
docs: document AnyKernel3 packaging
ci: cache the Clang toolchain
```

## Before opening a pull request

```bash
bash -n scripts/build.sh scripts/verify-source.sh scripts/package-anykernel.sh
./scripts/verify-source.sh
python3 scripts/check-links.py
./scripts/build.sh --dry-run
```

If you changed the kernel config or a driver, also do a real build following
[`docs/BUILDING.md`](docs/BUILDING.md) and include Clang/LLD versions in the PR description.

### Testing checklist for kernel changes

- [ ] Boots on at least one `miatoll` device (state the codename and ROM).
- [ ] Wi-Fi, Bluetooth, camera, fingerprint, audio, charging and deep sleep verified.
- [ ] `dmesg` free of new warnings; no regressed `pstore`/`ramoops` dumps.
- [ ] Stock `boot`/`dtbo` backup available for recovery.
- [ ] `CONFIG_LOCALVERSION` and the final `.config` recorded in the PR.
- [ ] AnyKernel3 `BLOCK`/slot settings verified against that ROM.

## Defconfig changes

Use the kernel's own tooling and review the diff:

```bash
./scripts/build.sh --menuconfig
# or: ./scripts/config --file out/.config -e SOME_SYMBOL
make O=out ARCH=arm64 savedefconfig
diff -u arch/arm64/configs/vendor/xiaomi/miatoll_defconfig out/defconfig
```

Only commit the reviewed defconfig delta, run `olddefconfig` afterwards, and explain every symbol.

## Pull requests

- Target `main` from a topic branch; see [`docs/BRANCHING.md`](docs/BRANCHING.md) for how the
  `17` development line relates to `main`.
- Fill in the pull request template with the provenance block (kernel release, defconfig, source
  commit, Clang/LLD versions, tested devices).
- `Validate` CI must pass. It checks only docs and SKYNET scripts — it does **not** build a
  kernel. Kernel builds happen in the `Build SKYNET kernel` workflow.

Issues: use the bug report template and always attach `dmesg`/`pstore` logs plus the exact device,
ROM and kernel version.
