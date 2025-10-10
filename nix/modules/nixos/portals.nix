{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.omnixy.portals;
in {
  options.omnixy.portals.enable = mkEnableOption "XDG portals for Hyprland/GTK" // { default = true; };

  config = mkIf cfg.enable {
    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = mkDefault [ "hyprland" "gtk" ];
    };
  };
}
