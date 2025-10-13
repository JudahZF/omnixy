# Changelog

## v0.1.0-preview — 2025-10-13

### Highlights
- Nix-first interface for Omarchy under the “omnixy” brand.
- Importable flake outputs: `nixosModules`, `homeManagerModules`, `overlays`, `packages`.
- Desktop profile (Hyprland, Waybar, Mako, terminals) with theme-aware wiring.
- Hardware + services: audio (PipeWire), zram, portals, printing.
- Graphics presets: Intel, AMD, and NVIDIA hybrid (Optimus) with PRIME sync.
- Hardware presets: laptop (power, NM+iwd), Bluetooth.
- Secrets examples and optional `sops-nix` shims (no hard dependency).
- CI: Linux flake checks, Alejandra formatting, generated options reference.
- Example consumer flakes for NixOS and Home Manager.

### Modules
- `nixos/modules/` root module `omnixy.nix` with override-friendly defaults.
- Submodules for audio, zram, graphics, greetd, printing, portals, hardware presets, secrets, tailscale.
- NVIDIA hybrid preset: `omnixy.hardware.nvidiaHybrid.*` (bus IDs + sync).

### Home Manager
- Base profile (`omnixy.enable`) and dotfiles option (`omnixy.files.enable`).
- Desktop module links Hyprland, Waybar, Mako, terminals (kitty/ghostty/alacritty) with theme files.
- New links: `fcitx5`, `fontconfig`, `xournalpp`, `fastfetch`, `lazygit`.
- Wallpaper: links `themes/<theme>/backgrounds` and starts `swaybg` via a user service.
- Waybar assets: ships default scripts/assets and custom `omarchy.ttf` glyph font.

### Overlay/Packages
- `omnixy-scripts` packages repo `bin/` tools.
- Fallback to `nixpkgs-unstable` for `walker`/`wl-screenrec` when missing in pinned channel.

### CI
- GitHub Actions runs `nix flake check --all-systems` on Ubuntu.
- Formatting check via Alejandra.
- Flake check emits `omnixy-nixos-options.md` using `nixosOptionsDoc`.

### Compatibility & Branding
- Options use `omnixy.*`. A compatibility module is provided for `omarchy.* -> omnixy.*`.
- Arch-era scripts are frozen; Omnixy (Nix) is the forward path.

### Migration Notes
- Import Omnixy as a flake input and add `nixosModules`/`homeManagerModules`.
- Set `omnixy.enable = true;` (and `omnixy.username`) in NixOS; enable desktop in HM if desired.
- See README sections “Omnixy (Nix) Usage” and “NVIDIA Hybrid (PRIME)”.

### Known Gaps
- Some Arch-era packages lack direct nixpkgs equivalents; alternatives may be needed.
- `homeManagerModules` output triggers a benign warning during flake checks.
- VM compositor assertions and more templates are planned.

### Verifications
- Evaluate/build: `nix flake check --all-systems --print-build-logs --show-trace`.
- Build scripts: `nix build .#omnixy-scripts`.

