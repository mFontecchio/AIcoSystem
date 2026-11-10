//! Mutating operations with journal (stubs for M4/M5).

use aico_core::{AicoError, VolumeClass};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OperationState {
    Planned,
    Copying,
    Verified,
    SourceRenamed,
    LinkCreated,
    Committed,
}

pub fn assert_writable(class: VolumeClass, path: &str) -> Result<(), AicoError> {
    if !class.allows_write() {
        return Err(AicoError::VolumeReadOnly(path.to_string()));
    }
    Ok(())
}
