# Developer Guide

This repo centers on a Nix-first interface named Omnixy, with legacy Arch scripts retained for back-compat.

## Layout
- `nix/` — modules, overlays, tests
- `templates/` — flake templates for NixOS and Home Manager
- `bin/` — helper scripts (many legacy/Arch-focused)
- `themes/` — theme assets consumed by modules and configs
- `config/` — dotfiles/config fragments for desktop components
- `examples/` — reference Nix flakes for HM/NixOS

## Flake
- `flake.nix` defines module/overlay outputs and checks.
- Run `nix flake show` to explore outputs.
- Update inputs with `nix flake update` (review `flake.lock`).

## Checks
- Build or evaluate provided checks if any exist under `nix/tests` or flake outputs.
- Example VM compositor check (mentioned in README): `nix build .#checks.x86_64-linux.vm-hyprland`.

## Contributing
- Keep changes focused and aligned with existing patterns.
- Update docs alongside code; cross-link platform pages where helpful.
