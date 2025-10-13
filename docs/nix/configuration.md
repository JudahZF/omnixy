# Nix Configuration

- Modules live under `nix/modules/` and overlays under `nix/overlays/`.
- Templates under `templates/` help bootstrap projects.
- Secrets: see `secrets/` with `.sops.yaml.example` and `secrets.example.yaml`. Enable `sops-nix` and point modules at your encrypted file.
