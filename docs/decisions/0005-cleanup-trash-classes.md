# ADR 0005: Cleanup classes and trash semantics

**Status:** Accepted  
**Date:** 2026-03-24

## Context

User needs reversible cleanup on a full disk; OS trash does not free space until emptied; Windows Recycle Bin has quotas.

## Decision

**Classes**

1. **Regenerable** — pip, uv, torch hub caches, HF cache (explicit purge commands or direct delete after confirmation).
2. **Trashable** — default; OS trash via `trash` crate with preflight.
3. **Report-only** — foreign OS volume, root-owned, denylisted container stores.

**UI metrics**

- Bytes moved to trash
- Bytes reclaimable after user empties trash (or AIcoSystem-scoped purge)
- Flag when Windows may permanently delete due to quota

**Rules**

- Never permanent-delete without explicit user step.
- Refuse trash when trash directory is on another mount and copy-then-delete would be required on full disk (fail with reason).

## Consequences

- Activity view documents undo limits when trash is emptied outside the app.
