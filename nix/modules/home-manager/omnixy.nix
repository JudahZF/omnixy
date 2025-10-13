{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omnixy;
  inherit (lib) mkEnableOption mkIf mkDefault;
in {
  imports = [
    ./desktop.nix
    ./secrets.nix
  ];
  options.omnixy = {
    enable = mkEnableOption "Omnixy Home Manager profile";

    files.enable = mkEnableOption "Install omnixy dotfiles (starship, browser flags)";
  };

  config = mkIf cfg.enable {
    # Lightweight defaults that consumers can override
    programs.git.enable = mkDefault true;

    # Install a few repo-managed dotfiles when enabled
    xdg.configFile = mkIf cfg.files.enable {
      "starship.toml".source = ../../../config/starship.toml;
      "brave-flags.conf".source = ../../../config/brave-flags.conf;
      "chromium-flags.conf".source = ../../../config/chromium-flags.conf;

      # Input Method Editor
      "fcitx5".source = ../../../config/fcitx5;
      "fcitx5".recursive = true;

      # Fontconfig rules
      "fontconfig".source = ../../../config/fontconfig;
      "fontconfig".recursive = true;

      # App configs
      "xournalpp".source = ../../../config/xournalpp;
      "xournalpp".recursive = true;

      "fastfetch".source = ../../../config/fastfetch;
      "fastfetch".recursive = true;

      "lazygit".source = ../../../config/lazygit;
      "lazygit".recursive = true;
    };
  };
}
