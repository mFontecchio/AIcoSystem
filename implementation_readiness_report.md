# Implementation Readiness — Stage 9

**Target:** `docs/designs/aicosystem-v0.1-design.md` lines 265–546

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| egm-implementation-readiness | completed |
| egm-codebase-details | completed |
| egm-style | completed |

## Verdict

**Not ready** for M0–M2 execution under Zero-Decision Rule.

## Blockers

| ID | Topic | Action |
| -- | ----- | ------ |
| B1 | Volume stable id | Decide in M0; update ADR 0004; remove `linux:{mount_point}` placeholder before DB writes |
| B2 | SQLite DDL | Add full `001_init.sql` to design appendix |
| B3 | Regenerable purge | Pick file-delete vs CLI per cache type |
| B4 | Scan JSON schema | Single contract; remove `stub` shape |
| B5 | `rusqlite_migration` | Add to workspace per ADR 0001 |
| B6 | `FsRead`/`FsWrite` API | Document trait methods before M1 |

## Majors (selected)

- Tauri IPC types missing; M3 Overview/Evidence UI omitted from plan
- Walker denylist path list missing; glob catalog not in loader
- `catalog-spike.sh` misses multi-path TOML arrays
- Journal states incomplete vs ADR 0007
- CI/toolchain/rust mismatch; Tauri icons absent; `continue-on-error` on tauri job
- Verification plan needs milestone→test file map

## Scaffold note

Existing code already implements catalog loader, mountinfo, `assert_writable`, stub CLI/Tauri—plan should say **extend** not greenfield.
