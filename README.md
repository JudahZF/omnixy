# Omarchy

Turn a fresh Arch installation into a fully-configured, beautiful, and modern web development system based on Hyprland by running a single command. That's the one-line pitch for Omarchy (like it was for Omakub). No need to write bespoke configs for every essential tool just to get started or to be up on all the latest command-line tools. Omarchy is an opinionated take on what Linux can be at its best.

Read more at [omarchy.org](https://omarchy.org).

### Import and Override in your flake
- Add input: `omnixy.url = "github:your/repo"` (or local `path:../..`).
- NixOS: `modules = [ inputs.omnixy.nixosModules.default { omnixy.enable = true; omnixy.username = "me"; } ];`
- Home Manager: `imports = [ inputs.omnixy.homeManagerModules.default { omnixy.enable = true; omnixy.desktop.enable = true; } ];`
- Overlay: `nixpkgs.overlays = [ inputs.omnixy.overlays.default ];`

### Examples
- Home Manager: see `examples/hm/flake.nix` (links dotfiles and theme config).
- NixOS: see `examples/nixos/flake.nix` (minimal evaluable demo).

## Omnixy (Nix) Usage

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

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).

