# Troubleshooting

- Hyprland doesn’t start via greetd:
  - Ensure `omnixy.login.greetd.enable = true;` and verify `tuigreet` is installed.
- Missing packages on stable channel:
  - Omnixy overlay can source specific packages from unstable automatically.
- Secrets errors with `sops`:
  - Verify `.sops.yaml` recipients and that `secrets/secrets.yaml` is encrypted.
