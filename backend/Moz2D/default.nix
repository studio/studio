# Moz2D package for the Firefox graphics routines needed for Pharo.
{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv;

let
  firefox-file = "FIREFOX_AURORA_52_BASE.zip";
  firefox-src = fetchurl {
    url = "https://hg.mozilla.org/mozilla-central/archive/${firefox-file}";
    sha256 = "1gdy1x6sp8vcmjfk9n6lfix7897biwy5ihvrrp1yly4bgr9fj1aw";
  };
in

mkDerivation {
  name = "Moz2D";
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
    echo "Re-packaging source as tar.gz"
    echo "Unzipping..."
    mkdir tmp
    unzip -d tmp ${firefox-file} >/dev/null
    pushd tmp
    echo "Taring..."
    tar czf ../${(lib.removeSuffix ".zip" firefox-file) + ".tar.gz"} *
    popd
    rm -rf tmp
    # Fix for build issue https://bugzilla.mozilla.org/show_bug.cgi?id=1329272
    cp ${./sedm4.patch} patches/sedm4.patch
    # cmake available during build (but not used for this derivation)
    PATH=$PATH:${cmake}/bin
    sh ./build.sh --arch x86_64
    mkdir -p $out/lib
    # Prevent runtime error due to depending on both gtk2 and gtk3
    patchelf --debug --remove-needed libgtk-3.so.0 build/libMoz2D.so
    cp build/libMoz2D.so $out/lib/
  '';
  nativeBuildInputs = [
    atk
    autoconf213
    cairo
    fontconfig
    freetype
    gcc5
    gdk_pixbuf
    glib
    gnome2.GConf
    gtk3
    gtk3-x11
    gtk2
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

