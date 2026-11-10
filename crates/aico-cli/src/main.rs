use aico_core::catalog::load_catalog_dir;
use aico_platform::list_volumes;
use clap::{Parser, Subcommand};
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "aico", version, about = "AIcoSystem CLI")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Scan and emit inventory JSON (stub)
    Scan {
        #[arg(long, default_value = "catalog")]
        catalog: PathBuf,
        #[arg(long)]
        json: bool,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Commands::Scan { catalog, json } => {
            let sigs = load_catalog_dir(&catalog)?;
            let volumes = list_volumes();
            let out = serde_json::json!({
                "status": "stub",
                "catalog_signatures": sigs.len(),
                "volumes": volumes,
                "locations": [],
            });
            if json {
                println!("{}", serde_json::to_string_pretty(&out)?);
            } else {
                println!("{out:#}");
            }
        }
    }
    Ok(())
}
