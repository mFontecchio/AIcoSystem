use serde::Deserialize;
use std::path::Path;

#[derive(Debug, Deserialize)]
pub struct CatalogFile {
    pub signatures: Vec<Signature>,
}

#[derive(Debug, Deserialize)]
pub struct Signature {
    pub id: String,
    pub owner: String,
    pub linux_paths: Vec<String>,
    pub markers: Vec<String>,
    pub movable: bool,
}

pub fn load_catalog_dir(dir: &Path) -> anyhow::Result<Vec<Signature>> {
    let mut out = Vec::new();
  if !dir.is_dir() {
        return Ok(out);
    }
    for entry in std::fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();
        if path.extension().is_some_and(|e| e == "toml") && path.file_name().is_some_and(|n| n != "schema.toml") {
            let text = std::fs::read_to_string(&path)?;
            let parsed: CatalogFile = toml::from_str(&text)?;
            out.extend(parsed.signatures);
        }
    }
    Ok(out)
}
