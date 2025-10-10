{ config, lib, ... } @ args:
let
  inherit (lib) mkEnableOption mkIf mkDefault mkMerge mkOption types attrByPath;
  cfg = config.omnixy.tailscale;
  hasSops = args ? sops-nix;
  secretPath = name: attrByPath [ "sops" "secrets" name "path" ] null config;
in {
  options.omnixy.tailscale = {
    enable = mkEnableOption "Enable Tailscale VPN";

    useSecret = mkEnableOption "Use sops-nix managed secret for auth key" // { default = true; };

    secret = {
      name = mkOption {
        type = types.str;
        default = "tailscale-auth-key";
        description = "Name of sops secret to use (under sops.secrets).";
      };
      file = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Optional sops file path to declare the secret from (YAML).";
      };
      key = mkOption {
        type = types.nullOr types.str;
        default = "example.tailscaleAuthKey";
        description = "YAML key path in the sops file (dot notation).";
      };
    };

    extraUpFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra flags for tailscale up (e.g., ["--ssh"]).";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.tailscale.enable = mkDefault true;
      services.tailscale.extraUpFlags = cfg.extraUpFlags;
    }

    # Declare the secret via sops-secrets if requested and sops-nix is present
    (mkIf (cfg.useSecret && hasSops && cfg.secret.file != null && cfg.secret.key != null) {
      sops.secrets."${cfg.secret.name}" = {
        sopsFile = cfg.secret.file;
        key = cfg.secret.key;
      };
    })

    # Wire the secret into Tailscale
    (let p = secretPath cfg.secret.name; in mkIf (cfg.useSecret && p != null) {
      services.tailscale.authKeyFile = p;
    })
  ]);
}
