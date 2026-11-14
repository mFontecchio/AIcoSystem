# Consolidated Goldfish Review Report

**Target:** [docs/designs/aicosystem-v0.1-design.md](docs/designs/aicosystem-v0.1-design.md)  
**Mode:** Consolidated (Stages 5–9)  
**Date:** 2026-03-24

## Executive summary

The v0.1 architecture (four crates, catalog TOML, volume-class gating, journal-first ops) matches the RFC and PRD. The design **does not yet pass** feature-spec or implementation-readiness bars. One **Blocker** repeats across stages: **volume stable identity** is open while Accepted ADRs and M1–M2 work assume persisted UUIDs. A second theme is **documentation debt**: missing **Risks & Mitigations**, undefined **denylist** and **preview contract**, and a **Detailed Implementation** section that duplicates GitHub issues and leaves too many `or` branches.

Recommended before coding M1: edit the design doc (or ADRs) to close Blockers B1–B6 below; trim implementation section to exit criteria; add Risks section.

## Reviewer status

| Stage | Reviewers | Artifact |
| ----- | --------- | -------- |
| 5 | zoom-out, inventive-catalyst | [zoom_out_report.md](zoom_out_report.md) |
| 6 | comprehension | [comprehension_report.md](comprehension_report.md) |
| 7 | design, structural, style | [critic_report.md](critic_report.md) |
| 8 | zoom-out | [intermediate_zoom_out_report.md](intermediate_zoom_out_report.md) |
| 9 | impl-readiness, codebase-details, style | [implementation_readiness_report.md](implementation_readiness_report.md) |

## Prioritized action items

### Blockers

| ID | Finding | Sources | Suggested fix |
| -- | ------- | ------- | ------------- |
| A1 | Volume stable id open; placeholder `linux:{mount_point}` | 5, 7, 8, 9 | M0 exit gate; document `blkid` + fallback; invalidate hash cache on id change |
| A2 | No Risks & Mitigations section | 7, 8 | New H2: scan/hash time, journal crash, NTFS/Btrfs, symlink failure, DB size |
| A3 | SQLite DDL absent | 9 | Appendix `001_init.sql` with columns/indexes |
| A4 | Scan JSON / IPC contracts undecided | 9 | One schema doc; M3 read-only commands only in design |
| A5 | `FsRead`/`FsWrite` + `rusqlite_migration` unspecified | 9 | API appendix; add migration dep to plan |

### Majors

| ID | Finding | Suggested fix |
| -- | ------- | ------------- |
| B1 | Denylist never defined | Static table + catalog-driven roots in Technical Plan |
| B2 | Journal states only in ADR 0007; reconciler “UI only” | Inline states; reconciler in `aico-ops` pre-mutation |
| B3 | Seven preview fields not enumerated | Struct list aligned with FR-13 |
| B4 | FR-06 NTFS skip; FR-18 in-use; CUJ gaps | Add CUJs + close open question 2 |
| B5 | M1 format sniff YAGNI | Remove from M1; optional magic at M5 |
| B6 | Implementation plan lines 265–516 too granular | Milestone exit criteria + issues.yaml |
| B7 | M0 overloaded | Narrow M0 per intermediate zoom-out |
| B8 | `podman` vs no-shell security line | Allowlist fixed subprocesses |
| B9 | Btrfs reclaimable stance | Decide v0.1 disclaimer vs detection |
| B10 | Foreign duplicate report-only | Export cleanup plan artifact (optional v0.1) |

### Nits

- Fix scan mermaid `Plat` participant
- Glossary: `.aico-old`, explain `dua`
- NFR table complete NFR-02/04
- Rephrase “Rejected by author” with ADR links
- Remove subjective “honest/safe” where mechanism exists

## Traceability matrix (sample)

| Consolidated ID | Stage reports | PRD / ADR |
| --------------- | ------------- | --------- |
| A1 | zoom_out, critic, impl | FR-01; ADR 0004, 0008 |
| A2 | critic structural | feature-spec standard |
| A3 | impl readiness | NFR-03; ADR 0001 |
| B2 | comprehension, inventive | ADR 0007; FR-16 |
| B4 | design | FR-05, FR-06, FR-18 |
| B5 | zoom_out | — |

## Resolution (2026-03-24 follow-up)

| ID | Status | Where addressed |
| -- | ------ | --------------- |
| A1 | Resolved | [ADR 0004](docs/decisions/0004-identity-and-db-location.md); `aico-platform` `volume_stable_id` |
| A2 | Resolved | Design doc § Risks and Mitigations |
| A3 | Resolved | [migrations/001_init.sql](migrations/001_init.sql) |
| A4 | Resolved | [docs/api/scan-json-schema.md](docs/api/scan-json-schema.md); M3/M4 IPC split in design |
| A5 | Resolved | [docs/appendices/fs-api.md](docs/appendices/fs-api.md); `rusqlite_migration` in workspace |
| B1–B10 | Resolved | Design Technical Plan + CUJs + trimmed milestones |
| Nits | Resolved | Glossary (`dua`, `.aico-old`, denylist); mermaid `Plat`; NFR table |

## Next step for author

1. Re-run `/egm-review` on [docs/designs/aicosystem-v0.1-design.md](docs/designs/aicosystem-v0.1-design.md) if you want a second pass, or begin **M0** exit gates.
2. Commit and push when satisfied (agent does not commit).

---

*Consolidated by parent from Goldfish stage reports; no in-thread simulation.*
