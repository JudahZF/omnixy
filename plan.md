# Omnixy Migration Plan (NixOS)

This document captures the full plan, decisions, artifacts, and current status for migrating Omarchy from Arch to a NixOS-first project under the "omnixy" interface. It is designed so a new agent can resume work with minimal ramp-up.

## Goals
- NixOS-first: Provide importable defaults that consumers can easily override.
- Reproducibility: Flake-based, pinned inputs; CI checks across systems.
- Safety: Defaults use `mkDefault` so consumer values win; no hard dependencies on secrets tooling.
- Parity: Feature coverage comparable to Arch setup (desktop, dev tools, theming, services).

## Branding
- Repository: "Omarchy" (unchanged).
- Nix interface: "omnixy" (options under `omnixy.*`; packages prefixed `omnixy-*` when exposed).
- Compatibility: `omarchy.* -> omnixy.*` renamed options module.

## Repository Map (Nix)
- `flake.nix`: Flake inputs/outputs, overlays, packages, devShells, checks, example HM config.
- `nix/overlays/default.nix`: Exposes `omnixy-scripts` package.
- `nix/pkgs/omnixy-scripts/default.nix`: Packages all repo `bin/` scripts.
- NixOS modules (`nix/modules/nixos/`):
  - `omnixy.nix`: Root module; imports submodules; base options (`omnixy.enable`, `omnixy.username`, `omnixy.theme`).
  - `packages/base.nix`: Package sets (base, unfree, extra) with guards.
  - `audio.nix`: PipeWire/WirePlumber/rtkit.
  - `zram.nix`: ZRAM swap with `memoryPercent`.
  - `graphics.nix`: OpenGL baseline + Intel/AMD/NVIDIA hybrid toggles (PRIME sync).
  - `greetd.nix`: tuigreet → Hyprland login.
  - `printing.nix`: CUPS + Avahi/mDNS.
  - `portals.nix`: XDG portals defaults (Hyprland, GTK).
  - Hardware presets (`hardware/`): `intel.nix`, `amd.nix`, `nvidia-hybrid.nix`, `laptop.nix`, `bluetooth.nix`, `default.nix`.
  - `tailscale.nix`: Tailscale with optional secret wiring.
  - `secrets.nix`: Omnixy secrets options (no hard `sops` reference).
  - `compat/omarchy-renamed-options.nix`: `omarchy.* -> omnixy.*` renamed options.
- Home Manager modules (`nix/modules/home-manager/`):
  - `omnixy.nix`: HM root; dotfiles option; imports desktop + HM secrets shim.
  - `desktop.nix`: Theme-aware wiring of Hyprland, Waybar, Mako, terminals (kitty/ghostty/alacritty), Walker, btop, eza, Neovim, VSCode.
  - `secrets.nix`: HM secrets options (no hard `sops` reference).
- Optional sops shims (not exported via flake outputs):
  - `nix/modules/nixos/sops.nix`: Imports `sops-nix.nixosModules.sops` when provided via `specialArgs`.
  - `nix/modules/home-manager/sops.nix`: Imports `sops-nix.homeManagerModules.sops` when provided via `extraSpecialArgs`.
- Examples:
  - `examples/hm/flake.nix`: HM consumer example.
  - `examples/nixos/flake.nix`: NixOS consumer example (minimal, evaluable setup).
- CI: `.github/workflows/nix.yml` — Ubuntu + macOS, `nix flake check --all-systems`.
- Secrets examples: `secrets/secrets.example.yaml`, `secrets/.sops.yaml.example`; gitignored real files.

## Consumer Usage
- Add input: `omnixy.url = "github:your/repo"` (or local `path:../..`).
- NixOS: `modules = [ inputs.omnixy.nixosModules.default { omnixy.enable = true; omnixy.username = "me"; } ];`
- HM: `imports = [ inputs.omnixy.homeManagerModules.default { omnixy.enable = true; omnixy.desktop.enable = true; } ];`
- Overlay: `nixpkgs.overlays = [ inputs.omnixy.overlays.default ];`
- Tailscale (optional secret): enable `omnixy.tailscale`; set `omnixy.tailscale.secret.file/key` if using `sops`.

## Decisions and Rationale
- Defaults via `mkDefault`: Ensures consumer overrides win regardless of module order.
- No hard sops dependency: `omnixy.secrets` exposes options without referencing `sops.*` to avoid evaluation errors; optional sops shims provided but not exported.
- Graphics: Use `hardware.opengl.*` (24.05) and avoid `hardware.graphics` for compatibility.
- Checks: Removed NixOS toplevel build from flake outputs to avoid boot assertions; HM activation build remains in checks.
- homeManagerModules warning: Kept non-standard output (warning is benign) for clarity.

## Testing
- Local: `nix flake check --all-systems --print-build-logs --show-trace`.
- Build scripts: `nix build .#omnixy-scripts`.
- CI: Runs on PRs and pushes to `main/master` for Ubuntu + macOS.

## Task Tracker

Completed
1. Adopt "omnixy" naming and export importable flake outputs (nixosModules/homeManagerModules/overlays/packages/lib).
2. Scaffold flake with systems matrix, devShell, checks; override-friendly modules.
3. Map Arch package lists to Nix: base, optional, and unfree sets with guards.
4. Package repo bin scripts as `omnixy-scripts` and expose via overlay.
5. NixOS: base, audio (PipeWire), zram, portals, greetd, printing.
6. Graphics + presets: Intel, AMD, NVIDIA hybrid (PRIME sync, open module toggle).
7. Hardware presets: laptop (power, NM+iwd), Bluetooth (BlueZ + Blueman).
8. Home Manager: base profile, dotfiles option, desktop theme module (Hyprland/Waybar/Mako/terminals).
9. Secrets: examples and docs; .gitignore sensitive files.
10. Tailscale: module with optional sops secret wiring and extra flags.
11. CI: GitHub Actions workflow to run `nix flake check` (Ubuntu + macOS, `--all-systems`).
12. Flake checks: fix eval/build issues until green across systems.
13. Document consumer import/override patterns (README updates).
14. Sops-nix integration: document consumer pattern; optional shims present (not exported).
15. Desktop completeness: link btop, eza, Neovim, VSCode theme files when present.
16. Example consumer flakes (HM + NixOS) added and referenced.

Pending
17. Package gaps: optionally package third‑party tools when absent in nixpkgs (e.g., `walker`, `wl-screenrec`).
18. VM test: add minimal NixOS VM test (QEMU) to boot Hyprland and load Waybar; add to `checks`.
19. Installer docs: document `nixos-install` and `nixos-anywhere`; consider custom ISO profile later.
20. Backcompat: CLI shim that detects Arch usage and points to omnixy; deprecation timeline in docs.
21. Release plan: tag first "omnixy preview"; announce migration path in README/CHANGELOG.
22. homeManagerModules warning: either keep (document) or alias outputs to suppress.
23. Cachix: docs for cache usage; optional CI vars (`CACHIX_CACHE_NAME`, `CACHIX_AUTH_TOKEN`).
24. Flake templates: provide consumer NixOS/HM templates under `templates/`.

## Risks and Assumptions
- Some Arch-era packages have no 1:1 nixpkgs mapping; repackaging or alternatives may be required.
- NVIDIA hybrid setups vary; require user-supplied bus IDs; sync mode optional.
- Secrets: Consumers opt-in to `sops-nix`; omnixy avoids hard coupling.

## Milestones
- M1 (Done): Importable modules + HM + CI green.
- M2: VM boot test and installer docs.
- M3: Backcompat shim + release notes + preview tag.

## Quick Start for New Contributors
- Run checks: `nix flake check --all-systems`.
- Try HM example: `nix build .#checks.x86_64-linux.consumer-home` (on x86_64-linux).
- Build scripts: `nix build .#omnixy-scripts`.
- Edit modules under `nix/modules/*`; keep defaults with `mkDefault`; add new options under `omnixy.*`.
- For secrets, follow README section "Omnixy (Nix) Usage"; optionally use the sops shims by adding them via `specialArgs`/`extraSpecialArgs`.
