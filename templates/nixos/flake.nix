{
  description = "Template: NixOS consumer flake using Omnixy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # Replace with your repository location
    omnixy.url = "github:your/repo";
  };

  outputs = { self, nixpkgs, omnixy, ... }:
    let
      system = "x86_64-linux"; # adjust as needed
      pkgs = import nixpkgs { inherit system; overlays = [ omnixy.overlays.default ]; };
    in {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          omnixy.nixosModules.default
          {
            omnixy.enable = true;
            omnixy.username = "me"; # change to your user
            omnixy.login.greetd.enable = true; # enable graphical login
            networking.hostName = "myhost";
            system.stateVersion = "24.05";
          }
        ];
      };
    };
}
