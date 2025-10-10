{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkDefault mkIf mkOption types;
  cfg = config.omnixy.hardware.nvidiaHybrid;
in {
  options.omnixy.hardware.nvidiaHybrid = {
    enable = mkEnableOption "NVIDIA hybrid (Optimus) preset with PRIME sync";
    sync.enable = mkEnableOption "Enable PRIME sync (recommended)" // { default = true; };
    intelBusId = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "PCI:0:2:0";
      description = "Intel GPU Bus ID for PRIME (run `lspci`)";
    };
    nvidiaBusId = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "PCI:1:0:0";
      description = "NVIDIA GPU Bus ID for PRIME (run `lspci`)";
    };
    open = mkEnableOption "Use NVIDIA open kernel module";
  };

  config = mkIf cfg.enable {
    omnixy.graphics.intel.enable = mkDefault true;
    omnixy.graphics.nvidia.enable = mkDefault true;
    omnixy.graphics.nvidia.open = mkDefault cfg.open;

    hardware.nvidia.prime = mkIf (cfg.intelBusId != null && cfg.nvidiaBusId != null) ({
      intelBusId = cfg.intelBusId;
      nvidiaBusId = cfg.nvidiaBusId;
    } // (if cfg.sync.enable then { sync.enable = true; } else {}));
  };
}
