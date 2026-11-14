# Comprehension Test — Stage 6

**Target:** `docs/designs/aicosystem-v0.1-design.md` (FeatureRange 1–264, DetailedRange 265–546)

## What this proposes

AIcoSystem v0.1 is a local-first desktop tool for one power user on a dual-boot machine (Fedora primary) who needs to see how much disk AI-related software consumes, find byte-identical duplicates, clean up safely, and move whole directories to another drive while leaving a symlink at the old path so apps keep working. The product inventories what is already installed via a TOML catalog—not a plugin runtime—and performs only user-approved file operations on the currently booted OS. A Rust workspace shares logic between CLI and Tauri + React, with SQLite for inventory and an operation journal.

## How the existing system works, per this document

As described, the system separates read-only discovery from gated mutation. Scanning runs under `FsRead`: enumerate volumes and `VolumeClass`, load catalog, index phase then parallel walks without following symlinks, persist to SQLite. Mutations run in `aico-ops` after volume-class checks, with journal write-ahead and startup reconciler. GUI uses the same Rust APIs as `aico-cli`.

## Findings

| Severity | Count |
| -------- | ----- |
| Blocker  | 0     |
| Major    | 6     |
| Nit      | 6     |

**Major:** Denylist undefined; journal states externalized to ADR 0007; M4 “seven preview fields” not enumerated; scan diagram missing `Plat` participant; `reconciled` undefined; `dua` benchmark unexplained.

**Nits:** `.aico-old` not in glossary; FsRead/FsWrite unspecified; `same-file` unclear; M6 before milestone key; “Goldfish review” insider term; principle 1 vs Ops→Plat diagram tension.
