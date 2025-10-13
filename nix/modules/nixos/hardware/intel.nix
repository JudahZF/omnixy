{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkDefault mkIf;
in {
  options.omnixy.hardware.intel.enable = mkEnableOption "Intel graphics preset (VAAPI/VDPAU)";

  config = mkIf config.omnixy.hardware.intel.enable {
    omnixy.graphics.intel.enable = mkDefault true;
  };
}
