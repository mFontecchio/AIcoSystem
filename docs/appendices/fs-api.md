# Filesystem API traits (v0.1)

## `FsRead` (`aico-platform`)

Read-only operations used by scan and hash pipelines.

- `metadata(path) -> Metadata` (size, allocated blocks, inode/file id, mtime, ctime)
- `read_exact(path, offset, len) -> Vec<u8>` for partial hashes
- `list_mounts() -> Vec<MountedVolume>`
- `is_symlink(path) -> bool` (never follow symlinks during walk)

No create, rename, or delete methods on this trait.

## `FsWrite` (`aico-ops`)

Mutations only. Every method calls `reconcile_pending_operations()` first.

- `trash(paths)` — freedesktop trash with same-volume preflight
- `purge_regenerable(paths)` — direct unlink for catalog-tagged regenerable caches
- `move_directory(source, dest)` — journal-backed; see ADR 0006

`assert_writable(volume_class, path)` returns `AicoError::VolumeReadOnly` when `ForeignOs` or `Unknown`, or when path matches the denylist.

## Database

- Crate: `rusqlite` with `bundled` feature
- Migrations: `rusqlite_migration` crate; SQL files in [migrations/001_init.sql](../../migrations/001_init.sql)
- Open policy: refuse DB if `user_version` > app supports; copy DB before migrate; refuse migrate while journal has non-terminal operations