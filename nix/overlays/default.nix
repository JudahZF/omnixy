{ nixpkgs-unstable ? null }:
final: prev:
let
  unstable = if nixpkgs-unstable == null then null else import nixpkgs-unstable { system = prev.stdenv.hostPlatform.system; };
in
  { omnixy-scripts = prev.callPackage ../pkgs/omnixy-scripts {}; }
  // (if prev ? walker then {} else if unstable != null && unstable ? walker then { walker = unstable.walker; } else {})
  // (if prev ? wl-screenrec then {} else if unstable != null && unstable ? wl-screenrec then { wl-screenrec = unstable.wl-screenrec; } else {})
