# Critic Review — Stage 7

**Target:** `docs/designs/aicosystem-v0.1-design.md` lines 1–264

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| egm-design | completed |
| egm-structural | completed |
| egm-style | completed |

## Blockers

### Missing Risks & Mitigations section

* **Lenses:** design, structural
* **Scope:** FeatureRange; feature-spec standard
* **Recommendation:** Add H2 **Risks & Mitigations** covering scan/hash duration, journal failures, NTFS/Btrfs edge cases, symlink breakage, DB growth.

## Majors (deduplicated)

- Volume identity open vs Accepted ADRs 0004/0008 (design, zoom-out from stage 5)
- NTFS skip detection deferred vs PRD FR-06 (design)
- PRD FR-18 open-file refusal absent from CUJs/move section (design)
- `podman system df` vs “no arbitrary shell” security line (design)
- CUJ gaps: cleanup preview, undo, foreign NTFS UX (design)
- `cancel_scan` contract missing (design)
- Scalability limits unbounded for multi-TB (design)
- Btrfs reclaimable ship stance open vs Goals “trust numbers” (design)
- Scan mermaid missing `Plat` participant (design, structural, comprehension)
- Alternatives “Rejected by author” without linked artifacts (structural, style)
- Subjective “honest/safe” phrasing without mechanism (style)

## Nits

- NFR table skips NFR-02/NFR-04 rows
- List marker inconsistency across H2s
- Section ordering vs template
- Alternative boilerplate repetition (style)

**Verdict:** Feature spec portion does not pass standard until Risks section and volume-id / FR traceability gaps are addressed.
