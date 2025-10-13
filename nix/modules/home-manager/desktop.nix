{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption mkOption types;
  cfg = config.omnixy;

  themes = {
    "catppuccin-latte" = ../../../themes/catppuccin-latte;
    gruvbox = ../../../themes/gruvbox;
    kanagawa = ../../../themes/kanagawa;
    "matte-black" = ../../../themes/matte-black;
    nord = ../../../themes/nord;
    "osaka-jade" = ../../../themes/osaka-jade;
  };

  themeDir = themes.${cfg.theme or "catppuccin-latte"};

  has = file: builtins.pathExists (themeDir + "/" + file);

  backgroundsDir = themeDir + "/backgrounds";
  hasBackgrounds = builtins.pathExists backgroundsDir;
  wallpaperFiles =
    if hasBackgrounds
    then builtins.attrNames (builtins.readDir backgroundsDir)
    else [];
  defaultWallpaper =
    if builtins.length wallpaperFiles > 0
    then backgroundsDir + "/" + builtins.elemAt wallpaperFiles 0
    else null;
in {
  options.omnixy = {
    desktop.enable = mkEnableOption "Enable omnixy desktop dotfiles (Hyprland, Waybar, etc.)" // {default = true;};

    theme = mkOption {
      type = types.enum (builtins.attrNames themes);
      default = "catppuccin-latte";
      description = "Theme directory name under themes/.";
    };
  };

  config = mkIf cfg.desktop.enable {
    # Hyprland base configs, with theme overrides where available
    xdg.configFile = (
      {
        "hypr/autostart.conf".source = ../../../config/hypr/autostart.conf;
        "hypr/bindings.conf".source = ../../../config/hypr/bindings.conf;
        "hypr/envs.conf".source = ../../../config/hypr/envs.conf;
        "hypr/hypridle.conf".source = ../../../config/hypr/hypridle.conf;
        "hypr/hyprsunset.conf".source = ../../../config/hypr/hyprsunset.conf;
        "hypr/input.conf".source = ../../../config/hypr/input.conf;
        "hypr/looknfeel.conf".source = ../../../config/hypr/looknfeel.conf;
        "hypr/monitors.conf".source = ../../../config/hypr/monitors.conf;
      }
      // (
        if has "hyprland.conf"
        then {"hypr/hyprland.conf".source = themeDir + "/hyprland.conf";}
        else {"hypr/hyprland.conf".source = ../../../config/hypr/hyprland.conf;}
      )
      // (
        if has "hyprlock.conf"
        then {"hypr/hyprlock.conf".source = themeDir + "/hyprlock.conf";}
        else {"hypr/hyprlock.conf".source = ../../../config/hypr/hyprlock.conf;}
      )
      # Waybar: base config + theme style
      // {
        "waybar/config.jsonc".source = ../../../config/waybar/config.jsonc;
        "waybar/style.css".source = themeDir + "/waybar.css";
      }
      # Mako notifications
      // (
        if has "mako.ini"
        then {"mako/config".source = themeDir + "/mako.ini";}
        else {}
      )
      # SwayOSD styling
      // (
        if has "swayosd.css"
        then {"swayosd/style.css".source = themeDir + "/swayosd.css";}
        else {}
      )
      # Terminals
      // (
        if has "alacritty.toml"
        then {"alacritty/alacritty.toml".source = themeDir + "/alacritty.toml";}
        else {}
      )
      // (
        if has "kitty.conf"
        then {"kitty/kitty.conf".source = themeDir + "/kitty.conf";}
        else {}
      )
      // (
        if has "ghostty.conf"
        then {"ghostty/config".source = themeDir + "/ghostty.conf";}
        else {}
      )
      # File manager helpers
      // (
        if has "walker.css"
        then {"walker/style.css".source = themeDir + "/walker.css";}
        else {}
      )
      # btop theme
      // (
        if has "btop.theme"
        then {"btop/themes/omnixy.theme".source = themeDir + "/btop.theme";}
        else {}
      )
      # eza theme
      // (
        if has "eza.yml"
        then {"eza/theme.yml".source = themeDir + "/eza.yml";}
        else {}
      )
      # Neovim theme snippet
      // (
        if has "neovim.lua"
        then {"nvim/lua/omnixy/theme.lua".source = themeDir + "/neovim.lua";}
        else {}
      )
      # VSCode settings (optional)
      // (
        if has "vscode.json"
        then {"vscode/settings.json".source = themeDir + "/vscode.json";}
        else {}
      )
      // (
        if has "backgrounds"
        then {
          "backgrounds/${cfg.theme}".source = themeDir + "/backgrounds";
          "backgrounds/${cfg.theme}".recursive = true;
        }
        else {}
      )
    );

    # Common programs toggles for desktop
    programs.waybar.enable = mkDefault true;
    services.mako.enable = mkDefault true;

    # Waybar assets and defaults
    xdg.dataFile = {
      "omarchy/default/hypr".source = ../../../default/hypr;
      "omarchy/default/hypr".recursive = true;
      "omarchy/default/waybar".source = ../../../default/waybar;
      "omarchy/default/waybar".recursive = true;
      # Custom glyph font for Omarchy icon in Waybar
      "fonts/omarchy.ttf".source = ../../../config/omarchy.ttf;
    };

    # Ensure per-user fontconfig, so the custom font is recognized
    fonts.fontconfig.enable = mkDefault true;

    # Provide OMARCHY_PATH for Waybar scripts
    home.sessionVariables.OMARCHY_PATH = "$XDG_DATA_HOME/omarchy";

    systemd.user.services.omnixy-wallpaper = mkIf (defaultWallpaper != null) {
      Unit = {
        Description = "Set wallpaper with swaybg";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${defaultWallpaper} -m fill";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
