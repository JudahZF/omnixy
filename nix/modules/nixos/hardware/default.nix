{ ... }:
{
  imports = [
    ./intel.nix
    ./amd.nix
    ./nvidia-hybrid.nix
    ./laptop.nix
    ./bluetooth.nix
  ];
}
