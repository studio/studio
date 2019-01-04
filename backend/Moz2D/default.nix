# 
{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv;

let
  firefox-file = "FIREFOX_AURORA_52_BASE.tar.gz";
  firefox-src = fetchurl {
    url = "https://hg.mozilla.org/mozilla-central/archive/${firefox-file}";
    sha256 = "10iz6gvxqzxkyp6jy6ri5lwag7rzi6928xw20j7qjssv63jll0ks";
  };
in

mkDerivation {
  name = "libmoz2d-dev";
  src = fetchFromGitHub {
    owner = "syrel";
    repo = "Moz2D";
    rev = "e8fc5f8e979c1c8f472e80b28942a627d2af1808";
    sha256 = "1qbz4sv1sy57mj0m290lw18zhlpqvf825m5nqglj5hh02401vj8n";
  };
  enableParallelBuilding = true;
  buildPhase = ''
    # Build script will detect the source archive by filename
    cp ${firefox-src} ${firefox-file}
    # Fix for build issue https://bugzilla.mozilla.org/show_bug.cgi?id=1329272
    cp ${./sedm4.patch} patches/sedm4.patch
    # cmake available during build (but not used for this derivation)
    PATH=$PATH:${cmake}/bin
    sh ./build.sh --arch x86_64
  '';
  buildInputs = [
    atk
    autoconf213
    cairo
    fontconfig
    freetype
    gdk_pixbuf
    glib
    gnome2.GConf
    gtk2
    gtk3
    libGL
    libpulseaudio
    nodejs
    pango
    perl
    pkgconfig
    python
    unzip
    which
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXt
    xorg.libxcb
    yasm
    zip
  ];
}

