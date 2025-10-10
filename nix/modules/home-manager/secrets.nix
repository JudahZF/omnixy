{ config, lib, ... } @ args:
let
  inherit (lib) mkEnableOption mkIf mkDefault mkOption types;
  cfg = config.omnixy.secrets;
  hasSops = args ? sops-nix;
in {
  options.omnixy.secrets = {
    hm.enable = mkEnableOption "Enable sops-nix in Home Manager";
    defaultSopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  imports = [ (if hasSops then args.sops-nix.homeManagerModules.sops else {}) ];

  config = mkIf (cfg.hm.enable && hasSops) {
    sops = {
      defaultSopsFile = mkIf (cfg.defaultSopsFile != null) cfg.defaultSopsFile;
    };
  };
}
