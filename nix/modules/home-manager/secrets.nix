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
    hm.enable = mkEnableOption "Enable sops-nix in Home Manager";
    defaultSopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = {};
}
