# RFC: AIcoSystem v0.1

**Status:** Published for feedback (mirror of [concepts_brief.md](../../concepts_brief.md))

* **Author:** mfontecchio
* **Date:** 2026-03-24

## Overview

AIcoSystem is a local-first desktop app for one power user on a dual-boot Fedora and Windows machine whose disk is full of AI applications, models, Python and Conda environments, caches, and containers that are hard to track across projects. Version 0.1 discovers those assets, reports size and content-hash duplicates with honest reclaimable space numbers, performs reversible cleanup (trash with explicit purge, plus safe purge of regenerable caches), and moves whole directories while leaving a symlink at the old path and writing a location report. Application configs are not rewritten. The stack is Tauri 2, Rust, React and TypeScript, and SQLite. Fedora is the primary development and test platform; Windows builds run in CI from day one. Development is solo at about 15–20 hours per week.

## Analysis

Seven independent review lenses (design, codebase details, zoom-out, comprehension, implementation readiness, structure, inventive catalyst) agree that the direction in `.research/idea.md` is right in spirit—unified inventory, safety-first lifecycle, Rust core—but the written plan describes a multi-year platform, not this release. The cut for v0.1 is deliberate.

**Scope and architecture.** Fifteen Rust crates, a full asset graph with provenance and confidence, GPU and compatibility engines, container lifecycle, install and update management, and a plugin sandbox are out of scope for v0.1. Four crates plus a CLI and a thin Tauri shell are enough: `aico-core` (catalog, scan, hash, database), `aico-ops` (journal, trash, move, reports), `aico-platform` (Linux and Windows adapters), and `apps/desktop`. Integrations are TOML signature files, not dynamically loaded plugins. The scanner depends only on a read-only filesystem trait; mutations go through `aico-ops` gated by volume class.

**Dual boot.** Windows cannot read Fedora’s default Btrfs natively. Fedora can read the Windows NTFS partition when it is mounted read-only (Fast Startup and BitLocker must be detected and explained). v0.1 scans one way: from Fedora, native volumes plus foreign NTFS read-only. Mutating operations never touch a foreign-OS volume; those assets are report-only until a later Windows-native build or a cross-OS action queue.

**Safety and UX.** Sending files to OS trash does not free space until the trash is emptied; the Windows Recycle Bin can permanently delete oversize items. The UI must show bytes trashed, bytes reclaimable after purge, and bytes at risk of permanent delete. “Used by” (catalog attribution) must not be confused with “file owner” (uid or ACL). Duplicate content is not the same as safe to remove if another path still references a copy. Every destructive action uses a fixed preview: paths, three size metrics, references, undo limits, and coverage of what was scanned or skipped.

**Sizes and duplicates.** Conda and uv hardlinks, Hugging Face snapshot symlinks, Btrfs compression and reflinks, and Snapper snapshots inflate naive totals. Report apparent size, allocated size, and exclusively reclaimable size. Hash with a size group, partial 1 MiB ends, then BLAKE3; cache by volume UUID, file identity, size, and mtime; treat Ollama and Hugging Face blob names as claimed SHA-256 only after verification before delete. Never walk into container overlay stores; report container disk use via API only.

**Operations.** Moves use a crash-safe journal flushed before each filesystem step: copy, verify, rename source to `.aico-old`, symlink at old path, write location report; user trashes `.aico-old` when satisfied. Windows directory moves use junctions where symlinks need privilege; single-file moves defer or require detected symlink privilege. Container stores, root-owned system paths, and files in use are denied.

**Efficiency.** Discovery should read existing indexes first (conda `environments.txt`, HF refs and blobs layout, Ollama manifests, `pyvenv.cfg`, Podman `system df`) before a parallel directory walk that does not follow symlinks. A catalog spike script should be compared to `dua` on the developer machine before heavy Rust work.

**Ideal final result (longer term).** One inventory assembled mostly from tool-maintained indexes, duplicate confirmation with minimal full-file reads, cleanup that frees space immediately where safe (hardlink or reflink dedup on same filesystem, regenerable cache purge) while keeping undo paths clear, and optional Windows-side execution of plans generated on Linux—without requiring a cloud backend.

## Goals vs. Non-Goals

* **In-scope goals (v0.1):**
  * Discover AI-related locations via a data-driven catalog and bounded filesystem walk on Fedora.
  * Read-only scan of the Windows NTFS partition when mounted, with clear skip reasons (hibernation, BitLocker, unmounted).
  * Report size metrics (apparent, allocated, reclaimable), catalog attribution, and scan coverage.
  * Content-hash duplicate groups with staged hashing and cache.
  * Reversible cleanup: trash with purge workflow, regenerable cache purge with confirmation, journal and undo where preconditions hold.
  * Move whole directories on native writable volumes with symlink, location report (JSON and Markdown), and link health checks.
  * Desktop viewer for overview, inventory, duplicates, cleanup preview, and activity.
  * CLI `aico scan --json` sharing the same core as the GUI.
  * CI: Fedora container for core tests, Ubuntu for Tauri build, Windows compile and targeted filesystem tests.

* **Out-of-scope non-goals (v0.1):**
  * Rewriting application configuration files.
  * Install, update, or uninstall of third-party AI apps.
  * GPU detection, model compatibility scoring, or inference.
  * Docker or Podman lifecycle (stop, remove images) beyond size reporting and suggested commands.
  * Plugin marketplace or unsigned third-party integrations.
  * Multi-machine fleet management, cloud sync, or telemetry.
  * Full asset relationship graph with automated cleanup authority.
  * Ubuntu as a primary test target; Windows-native scan and junction moves (planned as M6 after v0.1).
  * Flatpak distribution (sandbox blocks required paths).

## Alternatives Weighed

| Alternative | Reason not chosen for v0.1 |
| ----------- | --------------------------- |
| Ship the full `.research/idea.md` roadmap (6 milestones, 7 P0 epics, 15 crates) | Rejected by author after review: ~9–15 months part-time for one user; platform features without proven scan value. |
| Stability Matrix only for model folders | Rejected for product scope: AGPL; covers creative AI stacks but not Ollama, HF cache, conda, or cross-OS inventory. Useful reference for layout only. |
| czkawka / duplicate-only CLI | Rejected as sole product: no AI catalog, ownership, or safe move-with-link workflow. Hash pipeline ideas adopted. |
| Config rewriting on move instead of symlink or junction | Rejected: highest breakage risk; explicitly excluded from FeatureConcept. |
| Single shared SQLite DB on a shared data partition | Rejected for v0.1: stale cross-OS state; one DB per OS install with volume-relative identity. |
| SQLx async database | Rejected: local single-user store; `rusqlite` bundled with migration guard is simpler for Tauri. |
| Immediate permanent delete for “cleanup” | Rejected: contradicts reversibility; regenerable caches excepted with clear labeling. |
| Scan Windows partition from Windows build in v0.1 | Rejected: cannot read Linux root; Fedora-first delivers cross-OS visibility earlier. |

## Key Decisions & Staging for Next Steps

1. **Product name and license:** AIcoSystem, Apache-2.0; Tauri bundle id fixed early to avoid orphaning app data.
2. **Release slice:** M0–M5 for v0.1 (~12–16 weeks at 15–20 h/week); M6 Windows-native and Icebox items after first usable release.
3. **Volume model:** `VolumeClass` { NativeSystem, NativeData, ForeignOs, Unknown }; writes only on native writable volumes.
4. **Identity:** `(volume_uuid, volume_relative_path)`; optional `observed_from_os` for foreign snapshots.
5. **No config rewrite in v0.1;** location report documents official env vars (`OLLAMA_MODELS`, `HF_HOME`, etc.).
6. **Schema ~7 tables;** graph and compatibility tables deferred.
7. **GitHub Projects board** with milestones M0–M6, epics, and templated issues from `docs/backlog/backlog.md`.
8. **Next engineering step:** scaffold workspace, ADRs, initial catalog TOML, catalog spike script, then M1 CLI scan vertical slice.
