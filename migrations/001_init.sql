-- AIcoSystem schema v1 (see docs/designs/aicosystem-v0.1-design.md)

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS volumes (
    stable_id TEXT PRIMARY KEY,
    mount_point TEXT NOT NULL,
    fs_type TEXT NOT NULL,
    class TEXT NOT NULL CHECK (class IN ('native_system', 'native_data', 'foreign_os', 'unknown')),
    last_seen_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS scan_runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    started_at TEXT NOT NULL,
    finished_at TEXT,
    status TEXT NOT NULL CHECK (status IN ('running', 'completed', 'cancelled', 'failed')),
    coverage_json TEXT NOT NULL DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    scan_run_id INTEGER NOT NULL REFERENCES scan_runs(id) ON DELETE CASCADE,
    volume_stable_id TEXT NOT NULL REFERENCES volumes(stable_id),
    relative_path TEXT NOT NULL,
    used_by TEXT,
    confidence TEXT NOT NULL DEFAULT 'guessed',
    apparent_bytes INTEGER NOT NULL DEFAULT 0,
    allocated_bytes INTEGER NOT NULL DEFAULT 0,
    reclaimable_bytes INTEGER NOT NULL DEFAULT 0,
    observed_from_os TEXT NOT NULL DEFAULT 'linux',
    writable_actions INTEGER NOT NULL DEFAULT 0,
    UNIQUE (scan_run_id, volume_stable_id, relative_path)
);

CREATE INDEX IF NOT EXISTS idx_locations_run ON locations(scan_run_id);

CREATE TABLE IF NOT EXISTS catalog_matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    location_id INTEGER NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    signature_id TEXT NOT NULL,
    evidence TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS file_hashes (
    volume_stable_id TEXT NOT NULL,
    file_id TEXT NOT NULL,
    size_bytes INTEGER NOT NULL,
    mtime_ns INTEGER NOT NULL,
    ctime_ns INTEGER,
    partial_hash TEXT,
    full_hash TEXT,
    claimed_hash TEXT,
    verified INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (volume_stable_id, file_id, size_bytes, mtime_ns)
);

CREATE TABLE IF NOT EXISTS operations (
    id TEXT PRIMARY KEY,
    kind TEXT NOT NULL CHECK (kind IN ('trash', 'purge_regenerable', 'move_dir')),
    created_at TEXT NOT NULL,
    status TEXT NOT NULL,
    summary_json TEXT NOT NULL DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS operation_steps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operation_id TEXT NOT NULL REFERENCES operations(id) ON DELETE CASCADE,
    step_index INTEGER NOT NULL,
    state TEXT NOT NULL,
    recorded_at TEXT NOT NULL,
    detail_json TEXT NOT NULL DEFAULT '{}',
    UNIQUE (operation_id, step_index)
);