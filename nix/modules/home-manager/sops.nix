{ ... } @ args:
let
  hasSops = args ? sops-nix;
in {
  # Optional module that imports sops-nix’s Home Manager module if provided via extraSpecialArgs
  imports = [ (if hasSops then args.sops-nix.homeManagerModules.sops else {}) ];
}
