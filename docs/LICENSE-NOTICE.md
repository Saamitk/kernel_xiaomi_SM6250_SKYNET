# Licensing notice

This repository contains **two different bodies of code** with different licenses. Please read
this before changing [`../LICENSE`](../LICENSE) or vendoring kernel files.

## 1. Files committed here

The documentation, CI configuration and helper scripts committed to this repository
(`README.md`, `docs/`, `scripts/`, `.github/`) are licensed **GPL-3.0** — the license chosen when
the repository was created and recorded in [`../LICENSE`](../LICENSE). New contributions to those
files are expected under the same terms and are signed off per
[`../CONTRIBUTING.md`](../CONTRIBUTING.md).

## 2. The fetched Linux kernel source

`scripts/sync-source.sh` downloads a complete Linux kernel tree into an ignored `kernel/`
directory. That tree carries `SPDX-License-Identifier: GPL-2.0` (plus per-file exceptions and its
own `COPYING`/`LICENSES` files). It is **not** GPL-3.0 code, and fetching it does not relicense it.
Keep its license files intact and treat it as GPL-2.0-only for redistribution.

Consequences:

- Do not copy kernel C files into this repository without also copying the applicable GPL-2.0
  notices and documenting the change.
- Do not remove or replace the kernel tree's `COPYING` / SPDX headers.
- A flashable kernel you distribute must include the corresponding source (or a written offer),
  under the GPL-2.0 terms of the kernel code.

## 3. If you later vendor the source

If the `17` line eventually becomes a full kernel-source repository (rather than this
documentation/tooling home), the standard choice for a 4.14 Android kernel tree is **GPL-2.0**,
matching the Linux source. Changing a repository license is a maintainer decision that affects
every existing contribution, so discuss it in an issue first. Until then:

- keep `LICENSE` (GPL-3.0) for this repository's own scripts and docs;
- link to this notice from the README (already done in
  [`../README.md`](../README.md));
- state the kernel's GPL-2.0 status in every release's provenance file.

## 4. Third-party components

Toolchains (Clang/LLD, GNU cross binutils), AnyKernel3, KernelSU and similar projects each have
their own licenses. They are **not** bundled here and are only referenced from the documentation.

This notice is informational, not legal advice.
