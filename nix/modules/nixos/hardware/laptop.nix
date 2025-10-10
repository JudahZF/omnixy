{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkDefault mkIf;
  cfg = config.omnixy.hardware.laptop;
in {
  options.omnixy.hardware.laptop.enable = mkEnableOption "Laptop preset: power profiles, NetworkManager+iwd, upower" // { default = true; };

  config = mkIf cfg.enable {
    services.power-profiles-daemon.enable = mkDefault true;
    services.tlp.enable = mkDefault false;
    services.upower.enable = mkDefault true;

    networking.networkmanager = {
      enable = mkDefault true;
      wifi.backend = mkDefault "iwd";
    };
  };
}
