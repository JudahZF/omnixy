{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkDefault mkIf;
  cfg = config.omnixy.hardware.bluetooth;
in {
  options.omnixy.hardware.bluetooth.enable = mkEnableOption "Bluetooth stack (BlueZ + Blueman)" // {default = true;};

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = mkDefault true;
    services.blueman.enable = mkDefault true;
    environment.systemPackages = [pkgs.blueman];
  };
}
