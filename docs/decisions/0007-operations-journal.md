# ADR 0007: Operations journal and recovery

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Power loss or reboot mid-move can orphan data; dual-boot increases risk.

## Decision

Tables `operations` and `operation_steps`.

States: `Planned` → `Copying` → `Verified` → `SourceRenamed` → `LinkCreated` → `Committed` (+ `RollingBack` / `RolledBack` / `Failed`).

- Persist step **before** filesystem effect (write-ahead).
- `aico-ops::reconcile_pending_operations()` runs on process start and before every `FsWrite` call; desktop and CLI share this gate.
- Never delete source; use `.aico-old` until commit.
- Undo checks destination hash vs journal and old path occupancy.

## Consequences

- Property tests on state machine; crash injection hook in tests.
- Refuse DB migration if unfinished operations exist (or force reconcile first).
