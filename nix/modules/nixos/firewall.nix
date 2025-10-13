{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf mkDefault types;
  cfg = config.omnixy.firewall;
in {
  options.omnixy.firewall = {
    enable =
      mkEnableOption "Enable and configure a simple firewall (wraps networking.firewall)"
      // {default = true;};

    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "List of TCP ports to allow through the firewall.";
    };

    allowedUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "List of UDP ports to allow through the firewall.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      enable = mkDefault true;
      allowedTCPPorts = cfg.allowedTCPPorts;
      allowedUDPPorts = cfg.allowedUDPPorts;
    };
  };
}
