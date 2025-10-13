{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption mkOption types;
  cfg = config.omnixy.printing;
in {
  options.omnixy.printing = {
    enable = mkEnableOption "Printing via CUPS and Avahi" // {default = true;};

    pdf.enable = mkEnableOption "Enable virtual CUPS-PDF printer" // {default = false;};

    drivers = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional printer drivers to install (e.g., hplip, gutenprint).";
    };
  };

  config = mkIf cfg.enable {
    services.printing.enable = mkDefault true;
    services.printing.drivers = mkDefault cfg.drivers;

    # Discover network printers via mDNS/Avahi
    services.avahi = {
      enable = mkDefault true;
      nssmdns4 = mkDefault true;
      openFirewall = mkDefault true;
    };

    # Optional virtual PDF printer
    services.printing.cups-pdf.enable = mkIf cfg.pdf.enable (mkDefault true);
  };
}
