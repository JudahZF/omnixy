# Omnixy Migration Plan (NixOS)

This document captures the full plan, decisions, artifacts, and current status for migrating Omarchy from Arch to a Linux/NixOS-first project under the "omnixy" interface. It enables a new contributor/agent to resume work quickly.

## Goals
- NixOS-first: importable defaults, easy overrides.
- Reproducibility: flake-based, pinned inputs, CI checks.
- Safety: defaults via `mkDefault`; consumer overrides always win.
- Parity: cover desktop, dev tools, theming, services.
- Scope: Linux-only (NixOS + HM on Linux).

## Branding
- Repository: Omarchy (unchanged)
- Nix interface: omnixy (`omnixy.*` options; `omnixy-*` packages)
- Compatibility: `omarchy.* -> omnixy.*` renamed options module

## Repository Map (Nix)
- `flake.nix`: inputs/outputs, overlays, packages, devShells, checks, example HM config
- Overlays: `nix/overlays/default.nix` (exposes `omnixy-scripts`; falls back to unstable for `walker`/`wl-screenrec` when absent)
- Packages: `nix/pkgs/omnixy-scripts` (packages repo `bin/`)
- NixOS modules (`nix/modules/nixos/`):
  - `omnixy.nix`: root; imports submodules; base options (`omnixy.enable`, `omnixy.username`, `omnixy.theme`)
  - `packages/base.nix`: base/unfree/extra packages with guards
  - `audio.nix`: PipeWire/WirePlumber/rtkit
  - `zram.nix`: ZRAM swap with `memoryPercent`
  - `graphics.nix`: OpenGL baseline; Intel/AMD toggles; NVIDIA hybrid (PRIME sync)
  - `greetd.nix`: tuigreet → Hyprland login
  - `printing.nix`: CUPS + Avahi/mDNS
  - `portals.nix`: XDG portals defaults (Hyprland/GTK)
  - Hardware presets (`hardware/`): `intel.nix`, `amd.nix`, `nvidia-hybrid.nix`, `laptop.nix`, `bluetooth.nix`, `default.nix`
  - `tailscale.nix`: Tailscale with optional secret wiring
  - `secrets.nix`: omnixy secrets options (no hard `sops` dependency)
  - `compat/omarchy-renamed-options.nix`: `omarchy.* -> omnixy.*`
- Home Manager modules (`nix/modules/home-manager/`):
  - `omnixy.nix`: HM root; dotfiles option; imports desktop + HM secrets shim
  - `desktop.nix`: theme-aware wiring for Hyprland/Waybar/Mako/terminals (kitty/ghostty/alacritty)/Walker; extras (btop, eza, Neovim, VSCode) when present
  - `secrets.nix`: HM secrets options (no hard `sops` dependency)
- Examples:
  - `examples/hm/flake.nix`: HM consumer example
  - `examples/nixos/flake.nix`: NixOS consumer example (minimal evaluable setup)
- CI: `.github/workflows/nix.yml` — Linux (Ubuntu), `nix flake check --all-systems`
- Secrets examples: `secrets/secrets.example.yaml`, `secrets/.sops.yaml.example`; `.gitignore` for real secrets

## Consumer Usage
- Add input: `omnixy.url = "github:your/repo"` (or local `path:../..`)
- NixOS: `modules = [ inputs.omnixy.nixosModules.default { omnixy.enable = true; omnixy.username = "me"; } ];`
- HM: `imports = [ inputs.omnixy.homeManagerModules.default { omnixy.enable = true; omnixy.desktop.enable = true; } ];`
- Overlay: `nixpkgs.overlays = [ inputs.omnixy.overlays.default ];`
- Tailscale (optional secret): enable `omnixy.tailscale`; set `omnixy.tailscale.secret.file/key` if using `sops`

## Decisions and Rationale
- Defaults via `mkDefault` → user overrides win regardless of module order
- No hard `sops` dependency → avoids evaluation errors; optional shims available for consumers
- Graphics: use `hardware.opengl.*` (24.05-compatible); avoid `hardware.graphics`
- Checks: Linux-only; HM activation build; no VM tests required
- `homeManagerModules` output: non-standard; benign warning documented

## Testing
- Local: `nix flake check --all-systems --print-build-logs --show-trace`
- Build scripts: `nix build .#omnixy-scripts`
- CI: Runs on PRs and pushes to `main/master` on Ubuntu Linux

## Config Porting Coverage
Already wired via HM desktop module (theme-aware where present):
- Hyprland: base fragments under `config/hypr/*.conf` and theme overrides `themes/*/{hyprland.conf,hyprlock.conf}`
- Waybar: `config/waybar/config.jsonc` + theme `waybar.css`
- Hypridle/Hyprsunset/Input/Looknfeel/Monitors: from `config/hypr/*`
- Mako: theme `mako.ini` (optional)
- SwayOSD: theme `swayosd.css` (optional)
- Terminals: theme `alacritty.toml`, `kitty.conf`, `ghostty.conf` (optional)
- Walker: theme `walker.css` (optional)
- Dotfiles: `config/starship.toml`, `config/brave-flags.conf`, `config/chromium-flags.conf`
- Extras: theme `btop.theme`, `eza.yml`, `neovim.lua`, `vscode.json` (optional)

To port next (HM xdg.configFile):
- Fcitx5: link `config/fcitx5/*`
- Fontconfig: link `config/fontconfig/*` and ensure fonts via NixOS module
- Xournalpp: link `config/xournalpp/*`
- Fastfetch: link `config/fastfetch/*`
- Lazygit: link `config/lazygit/*`
- Backgrounds: wallpaper integration referencing `themes/*/backgrounds/*`
- Any Waybar icons/assets expected by themes

## Task Tracker

Completed
1. Adopt "omnixy" naming and export importable flake outputs (nixosModules/homeManagerModules/overlays/packages/lib)
2. Scaffold flake with systems matrix, devShell, checks; override-friendly modules
3. Map Arch package lists to Nix: base, optional, and unfree sets with guards
4. Package repo bin scripts as `omnixy-scripts` and expose via overlay
5. NixOS: base, audio (PipeWire), zram, portals, greetd, printing
6. Graphics + presets: Intel, AMD, NVIDIA hybrid (PRIME sync, open module toggle)
7. Hardware presets: laptop (power, NM+iwd), Bluetooth (BlueZ + Blueman)
8. Home Manager: base profile, dotfiles option, desktop theme module (Hyprland/Waybar/Mako/terminals)
9. Secrets: examples and docs; .gitignore sensitive files
10. Tailscale: module with optional `sops` secret wiring and extra flags
11. CI: GitHub Actions workflow to run `nix flake check` on Linux (Ubuntu, `--all-systems`)
12. Flake checks: fixed eval/build issues until green on Linux
13. Document consumer import/override patterns (README updates)
14. `sops-nix` integration: documented consumer pattern; optional shims present (not exported)
15. Desktop completeness: link btop, eza, Neovim, VSCode theme files when present
16. Example consumer flakes (HM + NixOS) added and referenced
17. Package gaps: prefer nixpkgs; fall back to nixpkgs-unstable for `walker`/`wl-screenrec` when absent
18. Backcompat: `bin/omarchy` shim detects Arch/NixOS and points to Omnixy; deprecation note in README
19. Release plan: README adds preview plan and migration path sections
20. `homeManagerModules` warning: documented as benign in README
21. Cachix: README docs and optional CI variables noted; step scaffolded in workflow

22. Config porting: add HM links for fcitx5, fontconfig, xournalpp, fastfetch, lazygit, backgrounds/wallpaper, Waybar assets
23. NVIDIA guide: document PRIME bus IDs, sync mode, multi-monitor notes
24. Module docs: generate option reference via `nixosOptionsDoc` in flake checks
25. Formatting: add `alejandra`/`nixfmt` lint to CI
27. Packaging decision: either rely on unstable overlay or package local derivations for `walker`/`wl-screenrec`

Completed
26. Templates: expose `templates` via flake (done) and add README pointers (tighten)
28. First release: tag v0.1.0-preview; finalize CHANGELOG and migration notes (tag created; CHANGELOG done)

## Risks and Assumptions
- Some Arch-era packages have no 1:1 nixpkgs mapping; repackaging or alternatives may be required
- NVIDIA hybrid setups vary; require user-supplied bus IDs; sync mode optional
- Secrets: consumers opt into `sops-nix`; omnixy avoids hard coupling

## Milestones
- M1 (Done): Importable modules + HM + CI green (Linux-only)
- M2: Config porting (remaining HM links) + installer docs finalized
- M3: Preview release tag + migration notes + packaging decision on `walker`/`wl-screenrec`

## Quick Start for New Contributors
- Run checks: `nix flake check --all-systems`
- Try HM example: `nix build .#checks.x86_64-linux.consumer-home` (on x86_64-linux)
- Build scripts: `nix build .#omnixy-scripts`
- Edit modules under `nix/modules/*`; keep defaults with `mkDefault`; add new options under `omnixy.*`
- For secrets, see README "Omnixy (Nix) Usage"; optional `sops` shims via `specialArgs`/`extraSpecialArgs`