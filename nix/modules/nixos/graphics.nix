{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.omnixy.graphics;
  has = lib.hasSuffix;

  intelPkgs = with pkgs; [
    intel-media-driver
    vaapiIntel
    libvdpau-va-gl
    vaapiVdpau
  ];
  amdPkgs = with pkgs; [
    vaapiVdpau
    libvdpau
  ];
  commonPkgs = with pkgs; [
    libva
    libvdpau
  ];
in
{
  options.omnixy.graphics = {
    enable = mkEnableOption "Graphics stack (OpenGL/VAAPI) baseline" // {
      default = true;
    };

    intel.enable = mkEnableOption "Intel VA-API/VDPAU support";
    amd.enable = mkEnableOption "AMD VA-API/VDPAU support";
    nvidia = {
      enable = mkEnableOption "NVIDIA drivers";
      open = mkEnableOption "Use NVIDIA open kernel modules";
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.enable {
      hardware.graphics = {
        enable = mkDefault true;
        extraPackages = mkDefault commonPkgs;
      };
    })

    (mkIf cfg.intel.enable {
      hardware.graphics.extraPackages = mkDefault (commonPkgs ++ intelPkgs);
      services.xserver.videoDrivers = lib.mkDefault [ "intel" ];
    })

    (mkIf cfg.amd.enable {
      hardware.graphics.extraPackages = mkDefault (commonPkgs ++ amdPkgs);
      services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" ];
    })

    (mkIf cfg.nvidia.enable {
      hardware.nvidia = {
        modesetting.enable = mkDefault true;
        open = mkDefault cfg.nvidia.open;
        powerManagement.enable = mkDefault true;
      };
      services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
    })
  ];
}
