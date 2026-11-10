# ADR 0008: Hashing and duplicate detection

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Full-file hashing of terabytes is too slow; accuracy still required before delete.

## Decision

- Algorithm: BLAKE3 for full hash; SHA-256 for cross-check with Ollama/HF claimed names.
- Pipeline: group by size → hash first and last 1 MiB → full hash collisions only.
- Cache in `file_hashes` table; skip rehash when identity key unchanged.
- Hardlinks: one inode → not duplicates; one reclaimable size.
- Walker: `ignore` crate, parallel, no symlink follow.
- Verify claimed hash before authorizing delete on regenerable or trash paths.

## Consequences

- Partial hash false positives possible; full hash confirms.
- mmap hashing avoided for mutable files during scan.
