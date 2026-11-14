# Glossary (v0.1)

**Used by**  
Catalog attribution: which AI tool or rule claims a directory (e.g. `ollama`, `huggingface-hub`). Not the same as file owner.

**File owner**  
Operating-system owner: Linux uid/gid or Windows ACL principal. Controls whether the app can trash or move without elevation.

**Volume class**  
`NativeSystem`, `NativeData`, `ForeignOs`, or `Unknown`. Mutations allowed only on native writable volumes unless explicitly extended in a future ADR.

**Foreign OS volume**  
A mount presenting another installed OS (e.g. NTFS with Windows user profile). Scanned read-only from Fedora in v0.1.

**Apparent size**  
Sum of file lengths as reported by the filesystem (may follow hardlink accounting policy per scan config).

**Allocated size**  
Bytes charged on disk (`st_blocks`-style), including compression effects on Btrfs.

**Reclaimable size**  
Bytes that would be freed if this specific copy were removed, counting each inode once across hardlinks.

**Duplicate (content)**  
Two or more paths whose verified content hash matches.

**Safe to remove**  
A path may be removed without breaking a catalog-attributed dependency; separate from duplicate status.

**Confidence**  
`Confirmed` (marker or tool index), `Likely` (path heuristic), or `Guessed` (large unknown folder). Guessed items never unlock silent delete.

**Regenerable cache**  
Storage that can be refetched (pip, uv, torch hub, HF blobs). May be purged with a distinct warning from trash workflow.

**Location report**  
Human and machine-readable record of moves: old path, new path, link type, hash, timestamp, official relocation env var.

**Operation journal**  
SQLite-backed state machine for trash and move steps, written before each filesystem effect.

**Catalog signature**  
One TOML entry: id, paths, markers, asset kind, movable flag, optional Windows paths.

**Coverage summary**  
Post-scan list of scanned roots, skipped volumes, and denied paths.

**Claimed hash**  
Digest implied by filename (Ollama/HF blob). Must be verified before delete authorizes.

**Denylist**  
Paths where the app never writes: container graph and layer stores, Docker/Podman state, system-owned mounts (flatpak runtime paths flagged separately), and any path marked `movable: false` in the catalog without an explicit user override.

**`.aico-old`**  
Suffix applied when renaming the original directory before placing a symlink at the old path during a move; leftover data lives under that name until the user trashes it.

**`dua`**  
Third-party disk usage analyzer CLI (Oledom) used as an acceptance baseline: compare catalog-root attributed bytes to ~90% of `dua` totals on the author machine ([prd-v1.md](prd-v1.md)).
