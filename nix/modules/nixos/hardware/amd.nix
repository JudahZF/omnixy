{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkDefault mkIf;
in {
  options.omnixy.hardware.amd.enable = mkEnableOption "AMD graphics preset (VAAPI/VDPAU)";

  config = mkIf config.omnixy.hardware.amd.enable {
    omnixy.graphics.amd.enable = mkDefault true;
  };
}
