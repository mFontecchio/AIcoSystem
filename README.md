# AIcoSystem

Local-first desktop tool to discover, size, deduplicate, and safely clean up AI-related files on a dual-boot Linux and Windows machine.

**Status:** v0.1 in development (Fedora-first).

## Docs

- [Concepts brief](concepts_brief.md)
- [PRD v0.1](docs/product/prd-v1.md)
- [Architecture decisions](docs/decisions/)
- [Backlog](docs/backlog/backlog.md)

## Build (Fedora)

```bash
sudo dnf install webkit2gtk4.1-devel openssl-devel librsvg2-devel \
  gcc gcc-c++ make pkg-config
cargo build --workspace
```

NVIDIA + Wayland: if the window is blank, try `export WEBKIT_DISABLE_DMABUF_RENDERER=1` before starting the app.

## CLI

```bash
cargo run -p aico-cli -- scan --help
```

## GitHub board

```bash
gh auth refresh -s project,read:project
./scripts/bootstrap-board.sh
```

## License

Apache-2.0. See [LICENSE](LICENSE).
