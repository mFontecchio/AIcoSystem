use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum VolumeClass {
    NativeSystem,
    NativeData,
    ForeignOs,
    Unknown,
}

impl VolumeClass {
    pub fn allows_write(self) -> bool {
        matches!(self, VolumeClass::NativeSystem | VolumeClass::NativeData)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScanLocation {
    pub volume_uuid: String,
    pub relative_path: String,
    pub catalog_id: Option<String>,
    pub apparent_bytes: u64,
    pub allocated_bytes: u64,
    pub reclaimable_bytes: u64,
}
