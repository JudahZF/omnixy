{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkEnableOption
    mkOption
    types
    optional
    ;
  cfg = config.omnixy.packages;

  basePackages =
    (with pkgs; [
      alacritty
      avahi
      bash-completion
      bat
      blueberry
      brightnessctl
      btop
      cargo
      clang
      cups
      cups-browsed
      cups-filters
      # cups-pdf (Needs implemeting as settings)
      docker
      docker-buildx
      docker-compose
      dust
      evince
      eza
      fastfetch
      fcitx5
      fcitx5-gtk
      # fcitx5-qt Doesn't exist in nixpkgs
      fd
      ffmpegthumbnailer
      fontconfig
      fzf
      gh
      gnome-calculator
      gnome-keyring
      gnome-themes-extra
      gum
      gvfs
      hypridle
      hyprland
      # hyprland-qtutils (no direct package; QT Wayland libs instead)
      hyprlock
      hyprpicker
      hyprshot
      hyprsunset
      imagemagick
      imv
      inetutils
      iwd
      jq
      kdePackages.kdenlive
      libsForQt5.qtstyleplugin-kvantum5
      kitty
      lazydocker
      lazygit
      less
      libyaml
      libqalculate
      libreoffice-fresh
      llvm
      localsend
      luarocks
      mako
      man-db
      mariadb-connector-c
      mise
      mpv
      nautilus
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      nerdfonts
      neovim
      obs-studio
      chromium
      pamixer
      pinta
      playerctl
      plocate
      plymouth
      postgresql
      power-profiles-daemon
      python3Packages.pygobject3
      qt5.qtwayland
      qt6.qtwayland
      ripgrep
      satty
      slurp
      starship
      (gnome.sushi)
      swaybg
      swayosd
      tuigreet
      system-config-printer
      tldr
      tree-sitter
      ufw
      unzip
      waybar
      wf-recorder
      whois
      wireless-regdb
      wireplumber
      wl-clipboard
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xmlstarlet
      xournalpp
      yaru-theme
      zoxide
    ])
    ++ lib.optional (pkgs ? uwsm) pkgs.uwsm
    ++ lib.optional (pkgs ? walker) pkgs.walker
    ++ lib.optional (pkgs ? wl-clip-persist) pkgs.wl-clip-persist
    ++ lib.optional (pkgs ? wl-screenrec) pkgs.wl-screenrec
    ++ lib.optional (pkgs ? ghostty) pkgs.ghostty
    ++ lib.optional (pkgs ? polkit_gnome) pkgs.polkit_gnome;

  unfreePackages = [
    pkgs."1password-cli"
    pkgs."1password-gui"
    pkgs.obsidian
    pkgs.signal-desktop
    pkgs.spotify
    pkgs.typora
  ];

in
{
  options.omnixy.packages = {
    enable = mkEnableOption "Install Omnixy base package set" // {
      default = true;
    };

    unfree.enable = mkEnableOption "Include common unfree apps (1Password, Obsidian, Signal, Spotify, Typora)";

    extra = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra packages to add on top of Omnixy base set.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      basePackages ++ cfg.extra ++ (if cfg.unfree.enable then unfreePackages else [ ]);

    # Allow unfree when requested
    nixpkgs.config.allowUnfree = mkIf cfg.unfree.enable (mkDefault true);
  };
}
