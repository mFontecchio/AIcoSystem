# ADR 0004: Asset identity and database location

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Same file has different absolute paths per OS and per boot. Dual boot may imply two app installs.

## Decision

- **One SQLite database per OS install** in platform app data dir (`~/.local/share/aicosystem/` on Linux).
- **Volume stable id (`stable_id`):** Persisted in `volumes.stable_id` and used in location and hash cache keys.
  - **Primary (Linux):** Filesystem UUID from `blkid -o export` for the mount source device when present and non-empty.
  - **Fallback:** `dev:{major}:{minor}` parsed from `/proc/self/mountinfo` mount source (stable across reboot for the same partition).
  - **Last resort:** `mp:{sha256(mount_point)}` only when mount source is a pseudo-fs (e.g. bind with no block device); logged at warning level.
- **Location identity:** `(volume_stable_id, volume_relative_path)`.
- Foreign volume rows tagged with scan timestamp and `observed_from_os = windows`.
- Hash cache key includes `volume_stable_id`, file id (inode / file index), size, mtime_ns, ctime_ns where available.
- When `stable_id` for a mount point changes (reformat, UUID fix), invalidate `file_hashes` rows for that volume and bump scan recommendation in UI.

## Consequences

- No shared DB on a neutral partition in v0.1.
- M0 **exit gate:** `list_volumes()` returns non-placeholder ids; unit test covers UUID and fallback paths.
- M6 may add export/import JSON between DBs.
