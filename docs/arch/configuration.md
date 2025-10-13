# Arch Configuration (Legacy)

- System and user configs live under `config/` and are applied by the legacy scripts.
- Environment variables: see `config/environment.d/`.
- Secrets: prefer transitioning to Nix + `sops-nix`; legacy scripts do not manage encryption.
