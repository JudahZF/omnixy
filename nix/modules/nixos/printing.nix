{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.omnixy.printing;
in {
  options.omnixy.printing.enable = mkEnableOption "Printing via CUPS and Avahi" // { default = true; };

  config = mkIf cfg.enable {
    services.printing.enable = mkDefault true;
    services.printing.drivers = mkDefault [];
    services.avahi = {
      enable = mkDefault true;
      nssmdns4 = mkDefault true;
      openFirewall = mkDefault true;
    };
  };
}
