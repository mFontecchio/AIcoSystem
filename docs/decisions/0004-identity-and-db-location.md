# ADR 0004: Asset identity and database location

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Same file has different absolute paths per OS and per boot. Dual boot may imply two app installs.

## Decision

- **One SQLite database per OS install** in platform app data dir (`~/.local/share/aicosystem/` on Linux).
- **Location identity:** `(volume_uuid, volume_relative_path)`.
- Foreign volume rows tagged with scan timestamp and `observed_from_os = windows`.
- Hash cache key includes volume UUID, file id (inode / file index), size, mtime_ns, ctime_ns where available.

## Consequences

- No shared DB on a neutral partition in v0.1.
- M6 may add export/import JSON between DBs.
