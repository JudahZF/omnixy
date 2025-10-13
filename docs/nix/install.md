# Nix Install

Quick start
- Add Omnixy as a flake input and import modules
- Use templates in `templates/` for NixOS or Home Manager

NixOS example
```nix
{ inputs, ... }: {
  imports = [ inputs.omnixy.nixosModules.default ];
  omnixy.enable = true;
  omnixy.username = "me";
  omnixy.login.greetd.enable = true; # optional
}
```

Home Manager example
```nix
{ inputs, ... }: {
  imports = [ inputs.omnixy.homeManagerModules.default ];
  omnixy.enable = true;
  omnixy.desktop.enable = true;
}
```

See also `examples/` for complete flakes and commands in the root README.
