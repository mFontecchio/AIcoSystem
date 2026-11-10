# ADR 0006: Move with link (no config rewrite)

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Moving AI assets must not break apps; config rewriting is excluded from v0.1.

## Decision

**Scope:** Whole directories only in v0.1 (model trees, env roots, cache roots).

**Steps**

1. Plan and journal `Planned`
2. Copy to destination staging
3. Verify hash/size
4. Rename source → `.aico-old`
5. Create symlink at original path (Linux); junction for directories on Windows (M6)
6. Verify resolution through old path
7. Write location report
8. User may trash `.aico-old` later

**No** editing of application config files in v0.1. Report lists official env vars (`OLLAMA_MODELS`, `HF_HOME`, `CONDA_PKGS_DIRS`, etc.).

**Deny:** container overlay roots, `/usr/share/ollama` service paths without policy, cross-subvolume move without copy path when rename fails.

## Consequences

- Flatpak apps may not follow symlinks outside sandbox; preflight warns.
- SELinux context warnings on Fedora; preserve mode and xattrs on copy where supported.
