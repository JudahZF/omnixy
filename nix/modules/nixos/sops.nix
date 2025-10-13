{...} @ args: let
  hasSops = args ? sops-nix;
in {
  # Optional module that imports sops-nix’s NixOS module if provided via specialArgs
  imports = [
    (
      if hasSops
      then args.sops-nix.nixosModules.sops
      else {}
    )
  ];
}
