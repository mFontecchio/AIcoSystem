# Goldfish Review Report — Stage 5 Initial Zoom Out

**Target:** `docs/designs/aicosystem-v0.1-design.md` (full file)

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| egm-zoom-out | completed |
| egm-inventive-catalyst | completed |

## Prioritized Findings

### Volume stable id unresolved before M1 persistence — Severity: Blocker

* **Reviewer Lens:** egm-zoom-out, egm-inventive-catalyst
* **Affected Scope:** Open Questions; ADR 0004; M0/M1/M2 implementation sections
* **Discrepancy Description:** Placeholder mount-point ids will invalidate `locations` and `file_hashes` when the scheme changes.
* **Rationale & Recommendation:** Make volume id mechanism an M0 exit gate; update ADR 0004; block duplicate features until fixed.

### M1 format sniff (GGUF/SafeTensors) — Severity: Major

* **Reviewer Lens:** egm-zoom-out
* **Affected Scope:** M1 `format/sniff.rs`
* **Discrepancy Description:** PRD v0.1 does not require format metadata; reintroduces platform creep.
* **Rationale & Recommendation:** Drop from M1; optional magic check at M5 move verify only.

### M3 IPC lists M4/M5 mutation commands — Severity: Major

* **Reviewer Lens:** egm-zoom-out
* **Affected Scope:** Desktop IPC list; M3 milestone
* **Discrepancy Description:** Conflicts with backlog staging (read-only M3).
* **Rationale & Recommendation:** Split IPC by milestone in the design doc.

### M0 milestone overloaded — Severity: Major

* **Reviewer Lens:** egm-zoom-out
* **Affected Scope:** M0 foundation section
* **Discrepancy Description:** Delays first `aico scan --json` vertical slice.
* **Rationale & Recommendation:** Narrow M0 exit criteria; defer Tauri icons/NVIDIA guard to M3.

### Journal reconciler UI-only gate — Severity: Major

* **Reviewer Lens:** egm-inventive-catalyst
* **Affected Scope:** ADR 0007 vs Technical Plan
* **Discrepancy Description:** CLI could mutate with incomplete journal if only GUI reconciles.
* **Rationale & Recommendation:** Run reconciler in `aico-ops` before any `FsWrite`, all entry points.

### Move always copies; btrfs same-fs rename ignored — Severity: Major

* **Reviewer Lens:** egm-inventive-catalyst
* **Affected Scope:** Move sequence; CUJ 3
* **Discrepancy Description:** Full copy on full disk is worst case for btrfs subvolume moves.
* **Rationale & Recommendation:** Plan-time branch: same filesystem rename/reflink path vs cross-mount copy path.

### Verified duplicates still trash-default — Severity: Major

* **Reviewer Lens:** egm-inventive-catalyst
* **Affected Scope:** Cleanup classes; Goals metrics
* **Discrepancy Description:** Reclaimable metrics disagree with user need on full disk.
* **Rationale & Recommendation:** Consider separate cleanup class for hash-verified duplicate eviction with journal undo (design decision).

### Foreign duplicate report-only in v0.1 — Severity: Major

* **Reviewer Lens:** egm-inventive-catalyst
* **Affected Scope:** Dual-boot goals
* **Discrepancy Description:** User sees reclaimable foreign bytes without action path.
* **Rationale & Recommendation:** Export cross-OS cleanup plan artifact from Linux scan for M6 or manual follow-up.

### Detailed Implementation Plan duplicates backlog altitude — Severity: Major

* **Reviewer Lens:** egm-zoom-out
* **Affected Scope:** Lines 265–516
* **Discrepancy Description:** File-level plan belongs in issues, not architecture doc.
* **Rationale & Recommendation:** Replace with milestone exit criteria + backlog pointer.

### Premature windows_paths in M0 catalog — Severity: Major

* **Reviewer Lens:** egm-zoom-out
* **Affected Scope:** M0 catalog
* **Rationale & Recommendation:** Linux-only catalog until M6.

## Nits

- ADR 0007 rollback states missing from journal list (egm-zoom-out)
- `aico-fixtures` crate premature (egm-zoom-out)
- catalog-spike Rust helper unnecessary (egm-zoom-out)
- NVIDIA WebKit guard belongs in M3 (egm-zoom-out)
- Tauri dual entry to core+ops (egm-inventive-catalyst)
- Regenerable purge strategy still open vs ADR 0005 (egm-inventive-catalyst)
