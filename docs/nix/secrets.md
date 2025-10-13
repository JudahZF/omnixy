# Secrets with sops-nix

Omnixy modules integrate cleanly with `sops-nix` for managing secrets.

## Repo layout
- Example files live under `secrets/`:
  - `secrets/secrets.example.yaml`: copy to `secrets/secrets.yaml` and encrypt with `sops`.
  - `secrets/.sops.yaml.example`: copy to repo root as `.sops.yaml` and set your `age` recipients.

## Module options
Enable and point modules at your encrypted file:

```nix
# In your NixOS config that imports omnixy
omnixy.secrets.enable = true;
omnixy.secrets.defaultSopsFile = ./secrets/secrets.yaml;
```

Define concrete secrets using keys inside the YAML:

```nix
sops.secrets."tailscale-auth-key" = {
  sopsFile = ./secrets/secrets.yaml;
  key = "example.tailscaleAuthKey";
};
```

## Encrypting
- Generate an age key: `age-keygen -o age.key` and record the public key (starts with `age1...`).
- Create `.sops.yaml` from the example and put your public key under `keys:`.
- Encrypt in-place: `sops -e -i secrets/secrets.yaml` (install `sops` if needed).

## Example: Tailscale
Recommended path through the Omnixy module:

```nix
omnixy.secrets.enable = true;
omnixy.tailscale.enable = true;
omnixy.tailscale.useSecret = true;
omnixy.tailscale.secret.file = ./secrets/secrets.yaml;
omnixy.tailscale.secret.key = "example.tailscaleAuthKey";
```

Direct wiring (alternative):

```nix
services.tailscale.authKeyFile = config.sops.secrets."tailscale-auth-key".path;
```
