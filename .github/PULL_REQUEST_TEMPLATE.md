## Summary

What does this PR change, and why?

## Type of change

- [ ] Documentation
- [ ] Build script / CI
- [ ] Upstream pin bump
- [ ] Other (describe below)

## Provenance (for kernel/build changes)

| Field | Value |
| --- | --- |
| `kernel.release` | |
| Defconfig | |
| Source commit | |
| Clang / LLD versions | |
| Tested devices (codename + ROM) | |

## Checklist

- [ ] Commits are small, focused and signed off (`git commit -s`).
- [ ] No `kernel/`, `out/`, images, ZIPs or logs are committed.
- [ ] `bash -n scripts/*.sh` passes.
- [ ] `./scripts/sync-source.sh --check` passes.
- [ ] `python3 scripts/check-links.py` passes.
- [ ] `./scripts/build.sh --dry-run` output matches the documented commands.
- [ ] `CHANGELOG.md` updated when the change is user-visible.
- [ ] Config changes explain the reason and the device tested (see `CONTRIBUTING.md`).
