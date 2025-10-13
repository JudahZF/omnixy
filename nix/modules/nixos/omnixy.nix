{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omnixy;
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
in {
  imports = [
    ./packages/base.nix
    ./audio.nix
    ./zram.nix
    ./graphics.nix
    ./greetd.nix
    ./printing.nix
    ./portals.nix
    ./hardware
    ./secrets.nix
    ./tailscale.nix
  ];
  options.omnixy = {
    enable = mkEnableOption "Omnixy base NixOS configuration";

    username = mkOption {
      type = types.str;
      default = "omnixy";
      description = "Default primary username (override in consumer flake).";
    };

    theme = mkOption {
      type = types.str;
      default = "catppuccin-latte";
      description = "Default theme name; must match a directory in themes/.";
    };
  };

  config = mkIf cfg.enable {
    # Sane defaults that are easy to override in consumer configs
    users.users.${cfg.username} = {
      isNormalUser = mkDefault true;
      description = mkDefault "Omnixy User";
      extraGroups = mkDefault ["wheel" "networkmanager"];
    };

    nix.settings.experimental-features = mkDefault ["nix-command" "flakes"];

    # Minimal, unobtrusive packages as defaults
    environment.systemPackages = with pkgs; [git];
  };
}
