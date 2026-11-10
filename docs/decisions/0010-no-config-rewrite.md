# ADR 0010: No application config rewrite in v0.1

**Status:** Accepted  
**Date:** 2026-03-24

## Context

`.research/idea.md` migration step 9 updates application configs. That broke the agreed FeatureConcept and poses highest user risk.

## Decision

v0.1 **forbids** modifying third-party config files (yaml, json, ini, registry) as part of move or cleanup.

Redirects rely on:

- Symlink or junction at old path
- Location report with manual env var guidance
- Optional user follow-up outside the app

Future versions may offer **opt-in** config rewrite behind separate ADR and per-app adapters.

## Consequences

- Epic and issues referencing "configuration path updates" are excluded from v0.1 backlog.
- Validation after move: resolve symlink and read sample bytes (e.g. GGUF magic) through old path.
