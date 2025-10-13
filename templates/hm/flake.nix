{
  description = "Template: Home Manager consumer flake using Omnixy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Replace with your repository location
    omnixy.url = "github:your/repo";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    omnixy,
    ...
  }: let
    system = "x86_64-linux"; # adjust as needed
    pkgs = import nixpkgs {
      inherit system;
      overlays = [omnixy.overlays.default];
    };
  in {
    homeConfigurations."me@localhost" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        omnixy.homeManagerModules.default
        {
          omnixy.enable = true;
          omnixy.desktop.enable = true; # includes Hyprland/Waybar/Mako and wlogout power menu

          # Optional: link Omnixy-managed dotfiles (starship, browser flags, etc.)
          omnixy.files.enable = true;

          home.username = "me"; # change to your user
          home.homeDirectory = "/home/me";
          home.stateVersion = "24.05";
        }
      ];
    };
  };
}
