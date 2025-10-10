{
  description = "Example NixOS consumer of omnixy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    omnixy.url = "path:../..";
  };

  outputs = { self, nixpkgs, omnixy, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        omnixy.nixosModules.default
        {
          networking.hostName = "omnixy-example";
          omnixy.enable = true;
          omnixy.username = "demo";
          users.users.demo.isNormalUser = true;
          # Minimal boot/filesystems for evaluation only
          boot.loader.grub.devices = [ "nodev" ];
          fileSystems."/" = { device = "nodev"; fsType = "tmpfs"; };
          system.stateVersion = "24.05";
        }
      ];
    };
  };
}
