{
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  pname = "omnixy-scripts";
  version = "0.1.0";

  src = ../../..; # repo root

  installPhase = ''
    mkdir -p $out/bin
    cp -r "$src/bin"/* $out/bin/
    chmod -R +x $out/bin || true
  '';

  meta = with lib; {
    description = "Packaged Omarchy utility scripts for Omnixy";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "omarchy-menu";
  };
}
