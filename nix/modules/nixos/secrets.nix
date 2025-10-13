{
  config,
  lib,
  ...
} @ args: let
  inherit (lib) mkEnableOption mkIf mkDefault mkOption types;
  cfg = config.omnixy.secrets;
  hasSops = false;
in {
  options.omnixy.secrets = {
    enable = mkEnableOption "Enable sops-nix for secret management";

    defaultSopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to default sops file (e.g., ./secrets/secrets.yaml).";
    };

    age = {
      generateKey = mkEnableOption "Generate age key on first boot" // {default = true;};
      keyFile = mkOption {
        type = types.path;
        default = "/var/lib/sops-nix/key.txt";
        description = "Path to age key file managed by sops-nix.";
      };
    };
  };

  config = {};
}
