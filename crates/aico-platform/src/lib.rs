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

    pub fn list_from_mountinfo() -> Vec<MountedVolume> {
        let Ok(text) = std::fs::read_to_string("/proc/self/mountinfo") else {
            return Vec::new();
        };
        let mut out = Vec::new();
        for line in text.lines() {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() < 10 {
                continue;
            }
            let mount_point = parts[4];
            let fs_type = parts
                .iter()
                .position(|p| *p == "-")
                .and_then(|i| parts.get(i + 2))
                .copied()
                .unwrap_or("unknown");
            let class = classify_linux(fs_type, mount_point);
            out.push(MountedVolume {
                uuid: format!("linux:{mount_point}"),
                mount_point: mount_point.to_string(),
                fs_type: fs_type.to_string(),
                class,
            });
        }
        out
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
