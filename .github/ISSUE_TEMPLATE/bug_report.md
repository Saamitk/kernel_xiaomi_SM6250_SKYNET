---
name: Bug report
about: Report a problem with a kernel build or with a flashed kernel
title: "[BUG] "
labels: bug
assignees: ''
---

**Before you file**

- [ ] I backed up my stock `boot` / `dtbo` images.
- [ ] I am using the pinned source and a config documented in `docs/BUILDING.md`.
- [ ] I searched existing issues first.

**Device and ROM**

| Field | Value |
| --- | --- |
| Device / codename | e.g. Redmi Note 9 Pro / `joyeuse` |
| ROM + Android version | |
| Kernel release (`uname -r`) | |
| Defconfig / config changes | |
| Source commit (pin) | |
| Clang and LLD versions | |

**What happened, and what you expected**

A clear, short description.

**Steps to reproduce**

1.
2.
3.

**Logs**

Attach `dmesg`, `pstore`/`ramoops` console logs, and the last kernel log before the failure.
Do not paste huge logs inline.

**Additional context**

Installed modules (Magisk/KernelSU), recovery used, whether the same issue happens on the stock
kernel, and anything else that helps reproduce it.
