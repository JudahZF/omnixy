{
  description = "Example Home Manager consumer of omnixy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    omnixy.url = "path:../..";
  };

  outputs = { self, nixpkgs, home-manager, omnixy, ... }: {
    homeConfigurations."demo@localhost" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ omnixy.overlays.default ]; };
      modules = [
        omnixy.homeManagerModules.default
        {
          omnixy.enable = true;
          omnixy.files.enable = true;
          omnixy.desktop.enable = true;
          omnixy.theme = "catppuccin-latte";
          home.username = "demo";
          home.homeDirectory = "/home/demo";
          home.stateVersion = "24.05";
        }
      ];
    };
  };
}
