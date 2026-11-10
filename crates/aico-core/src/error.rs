use thiserror::Error;

#[derive(Debug, Error)]
pub enum AicoError {
    #[error("volume is read-only: {0}")]
    VolumeReadOnly(String),
    #[error("database: {0}")]
    Database(#[from] rusqlite::Error),
    #[error("{0}")]
    Other(String),
}

pub type Result<T> = std::result::Result<T, AicoError>;
