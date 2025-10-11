{ lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  libdrm,
  libxkbcommon,
  ffmpeg,
}:

stdenv.mkDerivation rec {
  pname = "wl-screenrec";
  version = "0.4.0"; # update as needed

  src = fetchFromGitHub {
    owner = "emersion";
    repo = "wl-screenrec";
    rev = "v${version}";
    hash = lib.fakeHash; # replace with real hash when known
  };

  nativeBuildInputs = [ meson ninja pkg-config scdoc ];
  buildInputs = [ wayland wayland-protocols libdrm libxkbcommon ffmpeg ];

  meta = with lib; {
    description = "High-performance screen recorder for wlroots compositors (Wayland)";
    homepage = "https://github.com/emersion/wl-screenrec";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "wl-screenrec";
  };
}
