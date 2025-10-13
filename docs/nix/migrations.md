# Nix Migrations

- Repo `migrations/` contains scripts primarily for legacy paths. For Nix users, upgrades typically come from module changes.
- Use `nix flake update` to update inputs; review `flake.lock` diffs.
- Test via `nix build` checks where provided.
