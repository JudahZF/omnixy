{
  description = "Omnixy — Nix interface for Omarchy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in rec {
      # Importable modules with sensible, overrideable defaults
      nixosModules = {
        default = import ./nix/modules/nixos/omnixy.nix;
        compat-omarchy = import ./nix/modules/compat/omarchy-renamed-options.nix;
      };

      homeManagerModules = {
        default = import ./nix/modules/home-manager/omnixy.nix;
        compat-omarchy = import ./nix/modules/compat/omarchy-renamed-options.nix;
      };

      # Optional overlay (stub for now; extended as packages are added)
      overlays = {
        default = import ./nix/overlays/default.nix;
      };

      # Expose packages attrset per system
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
        in {
          default = pkgs.callPackage ./nix/pkgs/omnixy-scripts {};
          omnixy-scripts = pkgs.callPackage ./nix/pkgs/omnixy-scripts {};
        }
      );

      # Dev shell for formatting and nix work
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ alejandra nixfmt-rfc-style ];
          };
        }
      );



      homeConfigurations = {
        "demo@localhost" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ overlays.default ]; };
          modules = [
            homeManagerModules.default
            {
              omnixy.enable = true;
              omnixy.files.enable = true;
              omnixy.desktop.enable = true;
              omnixy.theme = "gruvbox";
              home.username = "demo";
              home.homeDirectory = "/home/demo";
              home.stateVersion = "24.05";
            }
          ];
        };
      };

      # Checks build the example configs (override precedence validated by evaluation/build)
      checks = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; overlays = [ overlays.default ]; };
        in {
          flake-evaluates = pkgs.runCommand "omnixy-flake-evaluates" {} "mkdir -p $out";
          consumer-home = if system == "x86_64-linux" then homeConfigurations."demo@localhost".activationPackage else pkgs.runCommand "skip-home-example" {} "mkdir -p $out";
        }
      );
    };
}
