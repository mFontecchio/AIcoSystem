# AIcoSystem — Product Requirements (v0.1)

**Status:** Accepted  
**Audience:** Single power user (author), dual-boot Fedora + Windows 11  
**License:** Apache-2.0

## Problem

The user’s disk is full. AI tools, models, environments, and caches were installed for many projects. Locations are scattered across home directories, package managers, container storage, and a second OS partition. The user cannot see total AI-related usage, find duplicates, or reclaim space without breaking an unknown dependency.

## Persona

One developer-researcher on Fedora (primary) who also boots Windows on the same machine. Works offline. Does not want a cloud account. Will grant write access only for explicit cleanup and move actions on the OS currently running.

## Functional requirements

| ID | Requirement |
| -- | ----------- |
| FR-01 | Enumerate mounted volumes and classify each as native system, native data, foreign OS, or unknown. |
| FR-02 | Load a versioned catalog of known AI tool locations (Linux paths, optional Windows paths, markers, confidence). |
| FR-03 | Discover locations from catalog matches and from a configurable walk (never follow symlinks; record denials). |
| FR-04 | Exclude container overlay stores from file-level walk and mutations; report container storage size via API when available. |
| FR-05 | When an NTFS Windows volume is mounted read-only, include it in scan results with `observed_from_os` and no write actions. |
| FR-06 | Detect NTFS skip reasons: not mounted, hibernated or dirty (Fast Startup), BitLocker locked. |
| FR-07 | For each location report apparent size, allocated size, and exclusively reclaimable size (inode-aware). |
| FR-08 | Attribute each location to a catalog entry (“used by”) or Unknown; show evidence (rule id, marker file). |
| FR-09 | Produce a scan coverage summary: roots scanned, skipped with reason, inaccessible paths. |
| FR-10 | Find duplicate file groups using staged hashing (size, partial, BLAKE3) with persistent cache. |
| FR-11 | Reuse claimed SHA-256 from Ollama and Hugging Face blob names; verify before any delete. |
| FR-12 | Present duplicate groups; block removal of a path that is the only copy referenced by a known tool unless user overrides with extra confirmation. |
| FR-13 | Cleanup preview shows trashed bytes, reclaimable-after-purge bytes, and permanent-delete risk on Windows. |
| FR-14 | Trash or purge only on native writable volumes; use OS trash APIs with preflight (Recycle Bin quota on Windows). |
| FR-15 | Allow purge of regenerable caches (pip, uv, torch hub, HF cache entries) with explicit regenerable labeling. |
| FR-16 | Record every mutation in an operations journal; reconcile incomplete operations at startup. |
| FR-17 | Move whole directories on native writable volumes: copy, verify, `.aico-old` rename, symlink at old path, location report. |
| FR-18 | Refuse move when target is container store, root-only path, foreign volume, or source has open files (best-effort). |
| FR-19 | Write location report as JSON and Markdown under app data and mirror summary on destination. |
| FR-20 | Desktop UI: Overview, Inventory, Duplicates, Cleanup (preview), Activity (undo where possible). |
| FR-21 | CLI: `aico scan` with JSON output equivalent to core scan result. |

## Non-functional requirements

| ID | Requirement |
| -- | ----------- |
| NFR-01 | Core scan must not write to discovered files. |
| NFR-02 | No network required for discovery or inventory. |
| NFR-03 | Database migrations forward-only; refuse to open DB from a newer app version. |
| NFR-04 | Typed errors surfaced to UI with stable codes. |
| NFR-05 | Scan progress throttled for UI; paginated queries for large inventories. |
| NFR-06 | RPM and AppImage targets for Fedora; no Flatpak in v0.1. |

## Acceptance criteria (release v0.1)

1. On the author’s Fedora machine, a scan reports at least 90% of AI-heavy byte usage compared to manual `dua` on catalog roots (documented in test notes).
2. A mounted read-only NTFS Windows partition appears in inventory without write actions enabled.
3. Duplicate groups match fixture trees with hardlinks, same-name different-content, and HF-style symlink blobs.
4. Trashing a test file moves it to OS trash; purge path frees space; journal records operation.
5. Moving a catalog `models`-style directory to another btrfs subvolume leaves a working symlink at the old path in integration fixture.
6. Interrupted move leaves journal state recoverable (resume or rollback) in crash-injection test.
7. Windows CI job builds workspace; Linux Fedora container runs core integration tests.

## Non-goals (v0.1)

See [concepts_brief.md](../../concepts_brief.md). Notably: config rewrite, GPU/compatibility engine, plugin SDK, fleet management, automatic deletion of unknown files.
