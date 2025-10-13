# Omarchy

Turn a fresh Arch installation into a fully-configured, beautiful, and modern web development system based on Hyprland by running a single command. That's the one-line pitch for Omarchy (like it was for Omakub). No need to write bespoke configs for every essential tool just to get started or to be up on all the latest command-line tools. Omarchy is an opinionated take on what Linux can be at its best.

Read more at [omarchy.org](https://omarchy.org).

Note: Omnixy targets Linux/NixOS only.

### Import and Override in your flake
- Add input: `omnixy.url = "github:JudahZF/omnixy"` (or local `path:../..`).
- NixOS: `modules = [ inputs.omnixy.nixosModules.default { omnixy.enable = true; omnixy.username = "me"; } ];`
- Home Manager: `imports = [ inputs.omnixy.homeManagerModules.default { omnixy.enable = true; omnixy.desktop.enable = true; } ];`
- Overlay: `nixpkgs.overlays = [ inputs.omnixy.overlays.default ];`

### Release Plan (Preview)
- v0.1.0-preview: Nix-first modules (NixOS + HM), `omnixy-scripts` packaging, overlay, CI checks green.
- Known gaps: optional third‑party packaging, VM compositor assertions, templates.
- Deprecation: Arch scripts frozen; use Omnixy via flakes going forward.

### Packaging Notes
- `walker` and `wl-screenrec`: Omnixy overlays fall back to `nixpkgs-unstable` if these packages are missing in the pinned stable channel. This keeps configs working without adding local derivations.
- If you already import an unstable overlay, you can drop Omnixy’s overlay or keep it — attribute resolution prefers your existing packages.

### Cachix (optional)
- CI supports Cachix if you set repository variables/secrets:
  - `CACHIX_CACHE_NAME` (Actions variable)
  - `CACHIX_AUTH_TOKEN` (Actions secret)
- The step is already present in `.github/workflows/nix.yml` and can be enabled by uncommenting.

### Migration Path
- Add Omnixy as a flake input and import the NixOS/HM modules.
- Set `omnixy.enable = true;` and your `omnixy.username` (and `omnixy.login.greetd.enable = true` for a graphical login).
- Optional: enable `omnixy.tailscale` and configure secrets with `sops-nix`.

### Examples
- Home Manager: see `examples/hm/flake.nix` (links dotfiles and theme config).
- NixOS: see `examples/nixos/flake.nix` (minimal evaluable demo).

### Templates
- Init from GitHub:
  - NixOS: `nix flake init -t github:JudahZF/omnixy#nixos`
  - Home Manager: `nix flake init -t github:JudahZF/omnixy#home-manager`
- Init from a local clone of this repo:
  - NixOS: `nix flake init -t path:../..#nixos`
  - Home Manager: `nix flake init -t path:../..#home-manager`
- Inspect available templates: `nix flake show github:JudahZF/omnixy`

### NixOS Install

Option A — nixos-install (on the target):
1) Boot the official NixOS 24.05 (or newer) installer ISO.
2) Partition/format your disks and mount the target root at `/mnt` (and `/mnt/boot`, etc.).
3) Generate hardware config: `nixos-generate-config --root /mnt`.
4) Use a consumer flake that imports Omnixy (see Examples). Minimal host module:
   ```nix
   { inputs, ... }: {
     imports = [ inputs.omnixy.nixosModules.default ];
     omnixy.enable = true;
     omnixy.username = "me";
     # Enable graphical login to Hyprland if desired
     omnixy.login.greetd.enable = true;
     networking.hostName = "myhost";
     system.stateVersion = "24.05";
   }
   ```
5) Install using a flake reference (local path or remote):
   - Local path (repo cloned in the installer): `nixos-install --no-root-password --flake /mnt/etc/nixos#myhost`
   - Remote flake: `nixos-install --no-root-password --flake github:your/repo#myhost`
6) Reboot and log in. Override any defaults in your host config as needed.

Option B — nixos-anywhere (from a control machine):
- Requires SSH access to the target (can be the installer ISO) and a consumer flake.
- Example:
  ```bash
  nix run github:numtide/nixos-anywhere -- \
    --flake github:your/repo#myhost \
    root@TARGET_IP
  ```
- Tips: add `--build-on-remote` for low-powered controllers; ensure your flake sets `omnixy.enable = true` and any secrets configuration if using `sops-nix`.

Optional — Custom ISO profile:
- You can build a bootable ISO from a NixOS module stack that imports Omnixy using tools like `nixos-generators`.
- Example (from your flake): `nix run github:nix-community/nixos-generators -- --format iso --flake .#myhost`.
- This is optional; `nixos-install` and `nixos-anywhere` are the primary paths.

## Omnixy (Nix) Usage

Note: Nix may warn `unknown flake output 'homeManagerModules'` during checks; this is benign and can be ignored.

- Example files live under `secrets/`:
  - `secrets/secrets.example.yaml`: copy to `secrets/secrets.yaml` and encrypt with `sops`.
  - `secrets/.sops.yaml.example`: copy to repo root as `.sops.yaml` and set your `age` recipients.
- Enable sops-nix and point to the file:
  - In your NixOS config that imports `omnixy`:
    - `omnixy.secrets.enable = true;`
    - `omnixy.secrets.defaultSopsFile = ./secrets/secrets.yaml;`
  - Define concrete secrets using keys inside the YAML:
    - `sops.secrets."tailscale-auth-key" = { sopsFile = ./secrets/secrets.yaml; key = "example.tailscaleAuthKey"; };`

Encrypting
- Generate an age key: `age-keygen -o age.key` and record the public key (starts with `age1...`).
- Create `.sops.yaml` from the example and put your public key under `keys:`.
- Encrypt: `sops -e -i secrets/secrets.yaml` (install `sops` if needed).

## Secrets Example
- Option A (recommended): enable omnixy’s Tailscale module and point it at the secret file/key.
  - `omnixy.secrets.enable = true;`
  - `omnixy.tailscale.enable = true;`
  - `omnixy.tailscale.useSecret = true;`
  - `omnixy.tailscale.secret.file = ./secrets/secrets.yaml;`
  - `omnixy.tailscale.secret.key = "example.tailscaleAuthKey";`
- Option B: wire directly
  - `services.tailscale.authKeyFile = config.sops.secrets."tailscale-auth-key".path;`

## Deprecation (Arch)

- Omarchy’s Arch-era scripts are frozen and considered deprecated.
- New features land in the Nix-first interface (“Omnixy”).
- A backcompat CLI shim `omarchy` now detects Arch and points to Omnixy usage.
- Migration path: adopt the Omnixy modules/overlays via flakes; see sections above.

## NVIDIA Hybrid (PRIME)

This guide helps configure NVIDIA hybrid (Optimus) laptops with PRIME and Hyprland.

1) Enable the preset in your NixOS host module:
```nix
{ inputs, ... }: {
  imports = [ inputs.omnixy.nixosModules.default ];
  omnixy.enable = true;

  # Enable NVIDIA hybrid (Optimus) support
  omnixy.hardware.nvidiaHybrid.enable = true;

  # Required: set your bus IDs (see next section)
  omnixy.hardware.nvidiaHybrid.intelBusId = "PCI:0:2:0";   # example
  omnixy.hardware.nvidiaHybrid.nvidiaBusId = "PCI:1:0:0";  # example

  # Optional: PRIME sync (reduces tearing); enabled by default
  # omnixy.hardware.nvidiaHybrid.sync.enable = true;

  # Optional: use NVIDIA open kernel module (supported GPUs only)
  # omnixy.hardware.nvidiaHybrid.open = true;
}
```

2) Find your bus IDs
- List GPUs: `lspci | rg -i "(vga|3d|display)"`
- Typical output shows something like:
  - Intel iGPU: `00:02.0 VGA compatible controller: Intel ...`
  - NVIDIA dGPU: `01:00.0 3D controller: NVIDIA ...`
- Convert to Nix format `PCI:<bus>:<device>:<function>`:
  - `00:02.0` → `PCI:0:2:0`
  - `01:00.0` → `PCI:1:0:0`

3) Multi‑monitor notes
- PRIME sync is recommended for smoother multi‑monitor setups; it is enabled by default.
- Configure layouts in Hyprland via `~/.config/hypr/monitors.conf` as usual.
- If you hit oddities (blank or flickering external display), try temporarily disabling sync:
  - `omnixy.hardware.nvidiaHybrid.sync.enable = false;`

4) Verify
- NVIDIA driver loaded: `nvidia-smi` (should show your GPU)
- PRIME configured: `journalctl -b | rg -i prime`
- Wayland monitors: `hyprctl monitors`
- GL/Vulkan device: `glxinfo -B | rg Device` or `vulkaninfo | rg -m1 "GPU id|deviceName"`

Notes
- The preset wires Intel and NVIDIA stacks and sets PRIME according to your IDs. It uses `hardware.graphics` and `hardware.nvidia.*` under the hood.
- The “open” NVIDIA kernel module may not support all GPUs/features; leave it off if unsure.

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
