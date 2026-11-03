# Licensing notice

The complete Linux kernel tree is now **in this repository**, so two licenses apply side by side.
Read this before changing [`../LICENSE`](../LICENSE) or reusing code.

## 1. Kernel source — GPL-2.0

The kernel tree at the root (`Makefile`, `arch/`, `drivers/`, `fs/`, `scripts/` from upstream, …)
carries `SPDX-License-Identifier: GPL-2.0` and ships its own `COPYING`, `CREDITS` and per-file
exceptions. That is the license for the vast majority of this repository.

- Keep `COPYING` and all SPDX headers intact.
- Do not relicense kernel code or copy it into a GPL-3.0-only project without the copyright
  holders' permission.
- A distributed kernel (including a flashable ZIP) must come with the corresponding source or a
  written offer, under GPL-2.0 terms.

## 2. SKYNET-authored files — GPL-3.0

The documentation, CI configuration, AnyKernel3 config and helper scripts written for this
project are licensed **GPL-3.0**, as recorded in [`../LICENSE`](../LICENSE):

- root `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`;
- `docs/`, `.github/`, `anykernel3/anykernel.sh`;
- `scripts/build.sh`, `scripts/verify-source.sh`, `scripts/package-anykernel.sh`,
  `scripts/check-links.py`.

New contributions to those files are expected under the same terms and are signed off per
[`../CONTRIBUTING.md`](../CONTRIBUTING.md).

> Because `scripts/` also holds upstream kernel build scripts, check a file's SPDX header before
> assuming which license applies. Upstream files keep GPL-2.0; SKYNET files carry
> `SPDX-License-Identifier: GPL-3.0-or-later`.

## 3. What this means for the repository license

- `COPYING` (GPL-2.0) is the **primary** license for the repository as a whole now that the tree
  is in-tree; GitHub's license detector may report "Other" because two license files are present.
- If you want a single declared license, **GPL-2.0** is the correct choice for a 4.14 Android
  kernel tree. Changing a repository license is a maintainer decision that affects every existing
  contribution, so discuss it in an issue first.
- Until then, keep both files and link to this notice from `README.md` (already done).

## 4. Third-party components

Clang/LLD and GNU cross binutils, [AnyKernel3](https://github.com/osm0sis/AnyKernel3), and any
KernelSU-like project each have their own licenses. AnyKernel3 is fetched at packaging time and
is **not** bundled in this repository. Toolchains are downloaded by CI, never committed.

This notice is informational, not legal advice.
