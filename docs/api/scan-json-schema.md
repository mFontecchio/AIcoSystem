# `aico scan --json` output (v0.1)

Single JSON object per scan. The `duplicates` array is present after the hash phase completes (or empty while hashing).

## Top-level fields

| Field | Type | Description |
| ----- | ---- | ----------- |
| `schema_version` | number | Always `1` for v0.1 |
| `scan_run_id` | number | SQLite `scan_runs.id` |
| `status` | string | `running`, `completed`, `cancelled`, or `failed` |
| `volumes` | array | Mounted volumes with class |
| `locations` | array | Catalog and walk hits |
| `coverage` | object | Scanned roots, skips, denials |
| `duplicates` | array | Confirmed duplicate groups |
| `hash_progress` | object | Optional while hashing |

## `volumes[]`

- `stable_id` (string): Filesystem UUID from `blkid` when available, else `dev:{major}:{minor}` from mount source
- `mount_point`, `fs_type`, `class` (`native_system` | `native_data` | `foreign_os` | `unknown`)

## `locations[]`

- `volume_stable_id`, `relative_path`
- `used_by` (string or null), `confidence` (`confirmed` | `likely` | `guessed`)
- `apparent_bytes`, `allocated_bytes`, `reclaimable_bytes`
- `observed_from_os` (`linux` | `windows`)
- `writable_actions` (boolean): false on foreign or unknown volumes

## `coverage`

- `scanned_roots` (string[])
- `skipped_volumes` ({ `mount_point`, `reason` }[]) — reasons: `unmounted`, `hibernated`, `dirty`, `bitlocker`, `not_ntfs`, `permission_denied`
- `inaccessible_paths` (string[])

## `duplicates[]`

- `full_hash` (string, BLAKE3 hex)
- `reclaimable_bytes` (number)
- `members` ({ `volume_stable_id`, `relative_path`, `writable_actions` }[])

## Cancellation

When the user cancels, `status` is `cancelled`, `locations` reflect the partial run, and `coverage` records how far the walk progressed. The client must not treat a cancelled run as a full inventory.