//! Platform volume and path helpers.

use aico_core::VolumeClass;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MountedVolume {
    pub uuid: String,
    pub mount_point: String,
    pub fs_type: String,
    pub class: VolumeClass,
}

pub fn list_volumes() -> Vec<MountedVolume> {
    #[cfg(target_os = "linux")]
    {
        return linux::list_from_mountinfo();
    }
    #[cfg(target_os = "windows")]
    {
        return windows::list_volumes_stub();
    }
    #[cfg(not(any(target_os = "linux", target_os = "windows")))]
    {
        Vec::new()
    }
}

#[cfg(target_os = "linux")]
mod linux {
    use super::*;
    use std::collections::HashMap;
    use std::path::Path;

    pub fn list_from_mountinfo() -> Vec<MountedVolume> {
        let Ok(text) = std::fs::read_to_string("/proc/self/mountinfo") else {
            return Vec::new();
        };
        let uuid_by_device = cache_uuid_by_block_device();
        let mut out = Vec::new();
        for line in text.lines() {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() < 10 {
                continue;
            }
            let major_minor = parts[2];
            let mount_point = parts[4];
            let sep = parts.iter().position(|p| *p == "-");
            let (fs_type, mount_source) = sep
                .map(|i| {
                    (
                        parts.get(i + 1).copied().unwrap_or("unknown"),
                        parts.get(i + 2).copied(),
                    )
                })
                .unwrap_or(("unknown", None));
            let class = classify_linux(fs_type, mount_point);
            let stable_id =
                volume_stable_id(mount_point, fs_type, major_minor, mount_source, &uuid_by_device);
            out.push(MountedVolume {
                uuid: stable_id,
                mount_point: mount_point.to_string(),
                fs_type: fs_type.to_string(),
                class,
            });
        }
        out
    }

    fn volume_stable_id(
        mount_point: &str,
        fs_type: &str,
        major_minor: &str,
        mount_source: Option<&str>,
        uuid_by_device: &HashMap<String, String>,
    ) -> String {
        if let Some(source) = mount_source.filter(|s| s.starts_with('/')) {
            if let Ok(canonical) = std::fs::canonicalize(source) {
                if let Some(uuid) = uuid_by_device.get(&canonical.to_string_lossy().into_owned()) {
                    return format!("uuid:{uuid}");
                }
            }
            if let Ok(uuid) = blkid_uuid(source) {
                return format!("uuid:{uuid}");
            }
            if major_minor != "0:0" {
                return format!("dev:{major_minor}");
            }
        }
        let mut hasher = blake3::Hasher::new();
        hasher.update(mount_point.as_bytes());
        hasher.update(b":");
        hasher.update(fs_type.as_bytes());
        format!("mp:{}", hasher.finalize().to_hex())
    }

    fn cache_uuid_by_block_device() -> HashMap<String, String> {
        let mut map = HashMap::new();
        let Ok(entries) = std::fs::read_dir("/dev/disk/by-uuid") else {
            return map;
        };
        for entry in entries.flatten() {
            let link = entry.path();
            let Some(uuid) = link.file_name().and_then(|s| s.to_str()) else {
                continue;
            };
            if let Ok(target) = std::fs::read_link(&link) {
                let device = if target.is_absolute() {
                    target
                } else {
                    Path::new("/dev").join(target)
                };
                if let Ok(canonical) = std::fs::canonicalize(&device) {
                    map.insert(canonical.to_string_lossy().into_owned(), uuid.to_string());
                }
            }
        }
        map
    }

    fn blkid_uuid(device: &str) -> Result<String, std::io::Error> {
        let output = std::process::Command::new("blkid")
            .args(["-o", "export", device])
            .output()?;
        if !output.status.success() {
            return Err(std::io::Error::other("blkid failed"));
        }
        let text = String::from_utf8_lossy(&output.stdout);
        for line in text.lines() {
            if let Some(uuid) = line.strip_prefix("UUID=") {
                if !uuid.is_empty() {
                    return Ok(uuid.to_string());
                }
            }
        }
        Err(std::io::Error::other("no UUID"))
    }

    fn classify_linux(fs_type: &str, mount_point: &str) -> VolumeClass {
        let ft = fs_type.to_lowercase();
        if ft.contains("ntfs") {
            return VolumeClass::ForeignOs;
        }
        if mount_point == "/" || mount_point == "/home" {
            return VolumeClass::NativeSystem;
        }
        if mount_point.starts_with("/run/media") || mount_point.starts_with("/mnt") {
            return VolumeClass::NativeData;
        }
        VolumeClass::Unknown
    }
}

#[cfg(target_os = "windows")]
mod windows {
    use super::*;

    pub fn list_volumes_stub() -> Vec<MountedVolume> {
        Vec::new()
    }
}
