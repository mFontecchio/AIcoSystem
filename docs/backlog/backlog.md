# AIcoSystem backlog (v0.1)

Source for GitHub milestones, epics, and issues. Machine-readable definitions: [issues.yaml](issues.yaml).

## Milestones

| Milestone | Target | Exit |
| --------- | ------ | ---- |
| M0 Foundation | 1–2 wk | Docs, ADRs, workspace, CI, catalog spike |
| M1 Read-only scan CLI | 2–3 wk | `aico scan --json` on Fedora |
| M2 Duplicates & dual boot | 2 wk | Hash pipeline, NTFS read-only scan |
| M3 Desktop viewer | 2–3 wk | Tauri inventory UI |
| M4 Reversible cleanup | 2–3 wk | Trash, journal, undo |
| M5 Move & v0.1 release | 2–3 wk | Symlink move, packaging |
| M6 Windows native | post-v0.1 | Junctions, Recycle Bin, import |
| Icebox | — | Parked future work |

## Epics (issue titles)

- **E-M0** Foundation and decisions
- **E-M1** Read-only scan engine
- **E-M2** Hashing, duplicates, foreign NTFS
- **E-M3** Desktop viewer and IPC
- **E-M4** Journal, trash, cleanup UI
- **E-M5** Move with link and release
- **E-M6** Windows-native operations
- **E-ICE** Icebox (no milestone date)

## Issue template

Each child issue in `issues.yaml` includes:

- Context, Contract, Acceptance (Given/When/Then), Platforms, Depends-on, Out of scope
- Labels: `type:*`, `area:*`, `platform:*`, `priority:*`
- Size: S / M / L
- Parent epic key: `E-M0` … `E-ICE`

## Dependency order (high level)

1. M0 → M1 (workspace before scan)
2. M1 → M2 (locations before hash)
3. M2 → M3 (data before UI)
4. M3 parallel M4 journal traits from M0/M1
5. M4 before M5 (journal before move)
6. M6 after M5

## Traceability

Functional requirements [prd-v1.md](../product/prd-v1.md) map to issues via `fr:` field in YAML.
