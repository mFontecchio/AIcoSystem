# Intermediate Zoom Out — Stage 8

**Target:** full design doc after Stages 6–7

## Verdict

Does not pass Zoom-Out Standard. Stage 5 Blocker (volume id) unchanged.

## Priority scope cuts (doc edits, not code)

1. M0 exit gate: stable volume id + ADR 0004 update before M1 persistence.
2. Replace Detailed Implementation file laundry list (265–516) with milestone exit criteria + `issues.yaml` pointer.
3. Split IPC: M3 read-only commands only.
4. Defer M1 format sniff, M0 windows_paths, premature fixtures crate, M0 Tauri/NVIDIA polish.
5. Reconciler runs in `aico-ops` before any mutation (CLI + GUI).
