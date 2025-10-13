{
  pkgs,
  lib,
  ...
}: let
  # Use the Python-based NixOS test framework
  makeTest = import (pkgs.path + "/nixos/tests/make-test-python.nix") {inherit pkgs lib;};
in
  makeTest {
    name = "omnixy-hyprland";

    nodes.machine = {
      pkgs,
      lib,
      ...
    }: {
      imports = [
        ../modules/nixos/omnixy.nix
      ];

      # Enable Omnixy and a simple greetd → Hyprland flow
      omnixy.enable = true;
      omnixy.username = "demo";
      omnixy.login.greetd.enable = true;
      # Autologin helps ensure a session is attempted without interaction
      omnixy.login.greetd.autologinUser = "demo";

      # Provide Waybar as a package (HM normally configures it)
      environment.systemPackages = [pkgs.waybar];

      users.users.demo = {
        isNormalUser = true;
        initialPassword = "demo";
        extraGroups = ["wheel"];
      };

      # Ensure VM has a graphics backend available
      virtualisation.graphics = true;

      # Typical ancillary requirements
      security.polkit.enable = true;

      # Keep stable across NixOS updates for the test VM
      system.stateVersion = "24.05";
    };

    testScript = ''
      start_all()
      # Boot to multi-user and ensure greetd is up (login manager)
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("greetd.service")

      # Sanity-check Hyprland and Waybar binaries are present
      machine.succeed("test -x ${pkgs.hyprland}/bin/Hyprland")
      machine.succeed("test -x ${pkgs.waybar}/bin/waybar")

      # Assert a user session exists for demo (autologin path)
      machine.wait_until_succeeds("loginctl list-sessions | grep -E '\\bdemo\\b'")

      # Assert Hyprland compositor started (process present)
      # Note: Headless VM reliability varies; this checks for process existence
      machine.wait_until_succeeds("pgrep -x Hyprland")
    '';
  }
