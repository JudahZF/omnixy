{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.omnixy.audio;
in {
  options.omnixy.audio = {
    enable = mkEnableOption "PipeWire/WirePlumber audio stack" // { default = true; };
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = mkDefault true;

    services.pipewire = {
      enable = mkDefault true;
      alsa.enable = mkDefault true;
      alsa.support32Bit = mkDefault true;
      pulse.enable = mkDefault true;
      jack.enable = mkDefault true;
    };
  };
}
