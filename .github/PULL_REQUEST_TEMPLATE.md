## Summary

What does this PR change, and why?

## Type of change

- [ ] Kernel source / driver / config
- [ ] Documentation
- [ ] Build script / CI
- [ ] AnyKernel3 packaging
- [ ] Upstream pin / re-import

## Provenance (for kernel/build changes)

| Field | Value |
| --- | --- |
| `kernel.release` | |
| Defconfig | |
| Source commit / pin | |
| Clang / LLD versions | |
| Tested devices (codename + ROM) | |

## Checklist

- [ ] Commits are small, focused and signed off (`git commit -s`).
- [ ] No `out/`, images, ZIPs, logs or toolchains are committed.
- [ ] `bash -n scripts/build.sh scripts/verify-source.sh scripts/package-anykernel.sh` passes.
- [ ] `./scripts/verify-source.sh` passes.
- [ ] `python3 scripts/check-links.py` passes.
- [ ] `./scripts/build.sh --dry-run` output matches the documented commands.
- [ ] `CHANGELOG.md` updated when the change is user-visible.
- [ ] Config changes explain the reason and the device tested (see `CONTRIBUTING.md`).
- [ ] AnyKernel3 block/slot settings verified against the target ROM.
