{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault mkEnableOption mkOption types;
  cfg = config.omnixy.zram;
in {
  options.omnixy.zram = {
    enable = mkEnableOption "Enable zram swap" // { default = true; };
    memoryPercent = mkOption {
      type = types.int;
      default = 25;
      description = "Percent of RAM to allocate to zram swap.";
    };
  };

  config = mkIf cfg.enable {
    zramSwap = {
      enable = mkDefault true;
      memoryPercent = mkDefault cfg.memoryPercent;
    };
  };
}
