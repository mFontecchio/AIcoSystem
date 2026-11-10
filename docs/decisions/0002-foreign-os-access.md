# ADR 0002: Foreign OS partition access

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Dual-boot machine: Fedora (Btrfs) and Windows (NTFS). User wants visibility into both; v0.1 is Fedora-first.

## Decision

- **Scan direction v0.1:** From Fedora, scan native volumes plus any mounted NTFS volume classified as `ForeignOs`, **read-only at application level** regardless of mount rw flag mishaps.
- **Do not** mount volumes from the app; consume `/proc/self/mountinfo` (or Windows equivalent in M6).
- Detect and surface: unmounted, hibernated/dirty NTFS, BitLocker encrypted.
- Windows build in v0.1: compile and test only; no btrfs scan until M6 defines import or tooling.
- Path display: store volume UUID + relative path; show Linux mount path in UI with optional Windows-equivalent path when known.

## Consequences

- Duplicates spanning Linux and Windows are visible; cleanup on Windows side is report-only until M6.
- Optional later: offline NTUSER/SOFTWARE hive read for Windows env overrides.
