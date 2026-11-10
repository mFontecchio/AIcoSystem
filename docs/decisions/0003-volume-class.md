# ADR 0003: Volume classification and write gate

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Mutations must never write to the other OS partition or unknown mounts.

## Decision

Enum `VolumeClass`: `NativeSystem`, `NativeData`, `ForeignOs`, `Unknown`.

- Scanner uses `FsRead` only.
- `aico-ops` uses `FsWrite`; rejects if source or destination volume is `ForeignOs` or `Unknown`, or mount is not writable for native data operations.
- Container stores and denylisted paths are non-mutable even on native volumes.

## Consequences

- Type-level separation of scan vs ops crates.
- Integration tests assert foreign volume write rejection.
