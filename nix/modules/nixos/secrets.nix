{ config, lib, ... } @ args:
let
  inherit (lib) mkEnableOption mkIf mkDefault mkOption types;
  cfg = config.omnixy.secrets;
  hasSops = args ? sops-nix;
in {
  options.omnixy.secrets = {
    enable = mkEnableOption "Enable sops-nix for secret management";

    defaultSopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to default sops file (e.g., ./secrets/secrets.yaml).";
    };

    age = {
      generateKey = mkEnableOption "Generate age key on first boot" // { default = true; };
      keyFile = mkOption {
        type = types.path;
        default = "/var/lib/sops-nix/key.txt";
        description = "Path to age key file managed by sops-nix.";
      };
    };
  };

  imports = [ (if hasSops then args.sops-nix.nixosModules.sops else {}) ];

  config = mkIf (cfg.enable && hasSops) {
    sops = {
      defaultSopsFile = mkIf (cfg.defaultSopsFile != null) cfg.defaultSopsFile;
      age = {
        keyFile = mkDefault cfg.age.keyFile;
        generateKey = mkDefault cfg.age.generateKey;
      };
    };
  };
}
