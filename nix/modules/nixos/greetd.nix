{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkDefault mkEnableOption mkOption types;
  cfg = config.omnixy.login.greetd;
  user = config.omnixy.username or "omnixy";
  hyprCmd = ''Hyprland'';
  tuigreetCmd = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${hyprCmd}";
in {
  options.omnixy.login.greetd = {
    enable = mkEnableOption "Enable greetd with tuigreet for Wayland login";
    autologinUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Username to auto-login directly into Hyprland (optional).";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = mkDefault true;
      settings = {
        default_session = {
          command = mkDefault tuigreetCmd;
          user = mkDefault user;
        };
      } // (if cfg.autologinUser != null then {
        initial_session = {
          command = hyprCmd;
          user = cfg.autologinUser;
        };
      } else {});
    };

    # Ensure Hyprland is available as a session command
    programs.hyprland.enable = mkDefault true;
  };
}
