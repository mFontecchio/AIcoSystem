# AIcoSystem — Long-term vision (non-normative)

This document parks scope from `.research/idea.md` that is **not** part of v0.1. It informs direction only; [prd-v1.md](prd-v1.md) is authoritative for the current release.

## Platform intent (future)

A cross-platform desktop product that helps users **discover**, **manage**, and **optimize** local AI estates: applications, models, environments, containers, and storage. Target expansion may include teams and consistent environments, still local-first.

## Deferred capabilities

- Unified asset graph with relationship provenance (config, process, inference, manual).
- Plugin or integration SDK with capability manifests and sandboxing.
- Install, update, and uninstall integrations for Ollama, ComfyUI, and similar.
- Hardware and model compatibility intelligence (VRAM, quantization, runtime).
- Docker and Podman lifecycle beyond reporting (prune with guardrails).
- Multi-machine export/import and remote agents.
- Natural-language assistant over inventory.
- Automated maintenance policies.
- Ubuntu LTS as a co-equal platform alongside Fedora.
- Windows-native full parity including btrfs access via defined method or import-only.
- Cross-OS action queue: plans generated on Linux executed on next Windows boot.
- Fast NTFS MFT enumeration; offline registry hive reads for Windows env vars.
- Hardlink/reflink in-place deduplication on same volume.
- Elevated helper for rare root-owned cleanup (minimal surface).

## Principles (carry forward)

- Local-first, no required cloud.
- Safe by default: preview, journal, reversibility where honest.
- Least privilege: no standing admin.
- Extensibility via data (catalog) before code (plugins).

## Relation to v0.1

v0.1 proves value on one dual-boot machine: inventory, honest sizes, duplicates, trash, and directory move with symlink. Everything in this vision file waits until that loop is reliable on the author’s hardware and CI.
