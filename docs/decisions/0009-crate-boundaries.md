# ADR 0009: Crate boundaries

**Status:** Accepted  
**Date:** 2026-03-24

## Context

`.research/idea.md` proposes 15+ crates; solo maintainer needs fewer boundaries.

## Decision

| Crate | Responsibility |
| ----- | ---------------- |
| `aico-core` | Domain types, catalog loader, scan orchestration, hash, DB access |
| `aico-ops` | Journal, trash, move, location reports |
| `aico-platform` | `cfg(linux)` / `cfg(windows)` volume enum, paths, trash adapters |
| `aico-cli` | Clap CLI |
| `apps/desktop` | Tauri + frontend |

Integrations live as `catalog/*.toml`. Split crates only when a new ADR justifies.

Fixture builder crate optional under `crates/aico-fixtures` for tests (M1+).

## Consequences

- Faster CI, less public API churn early in project.
