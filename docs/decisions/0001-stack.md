# ADR 0001: Application stack

**Status:** Accepted  
**Date:** 2026-03-24

## Context

Need a cross-platform desktop app with strong filesystem logic, local data, and a usable UI on Fedora first.

## Decision

- **Shell:** Tauri 2
- **Core:** Rust (2021 edition, MSRV pinned in CI)
- **UI:** React, TypeScript, Vite
- **Database:** SQLite via `rusqlite` with `bundled` feature and `rusqlite_migration`
- **IPC:** Tauri commands + `tauri-specta` for TypeScript types; progress via Channel, ~10 Hz
- **CLI:** `aico-cli` binary sharing `aico-core`

## Consequences

- No separate Python backend for environment discovery.
- WebKitGTK on Fedora requires documented build deps; NVIDIA+Wayland may need `WEBKIT_DISABLE_DMABUF_RENDERER=1`.
- Distribute RPM and AppImage; avoid Flatpak due to path sandbox limits.
