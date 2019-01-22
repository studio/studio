{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv.lib;

let libs = [
  Moz2D
  SDL2
  alsaLib
  cairo
  fontconfig
  freetype
  glib
  libGLU_combined
  libgcc
  libgit2
  libssh2
  libstdcxx5
  openssl
  libuuid
  openssl
  pango
  pixman
  xlibs.libXrender
  xlibs.libxcb
  xorg.libICE
  xorg.libSM
]; in


# Build the Pharo VM
stdenv.mkDerivation rec {
  name = "pharo";
  version = "git.${revision}";
  src = cleanSource /home/luke/git/opensmalltalk-vm;
#  src = fetchFromGitHub {
#    owner = "lukego";
#    repo = "opensmalltalk-vm";
#    rev = revision;
#    sha256 = "0v97qmwvr6k5iqx2yax4i5f7g2z9q6b3f2ym483pykhc167969cl";
#  };
  patches = [
    ./0001-sqUnixHeartbeat.c-Remove-warning-about-thread-priori.patch
  ];
  # This metadata will be compiled into the VM and introspectable
  # from Smalltalk. This has been manually extracted from 'git log'.
  #
  # The build would usually generate this automatically using
  # opensmalltalk-vm/.git_filters/RevDateURL.smudge but that script
  # is too impure to run from nix.
  revision = "f3be54a2657f31de321338645feef6b641b1a121";
  source-date = "Tue May 30 19:41:27 2017 -0700.1";
  source-url  = "https://github.com/OpenSmalltalk/opensmalltalk-vm";

  # Shared data (for the sources file)
  pharo-share = import ./share.nix { inherit stdenv fetchurl unzip runCommand; };

  # Note: -fPIC causes the VM to segfault.
  hardeningDisable = [ "format" "pic"
                       # while the VM depends on <= gcc48:
                       "stackprotector" ];

  # Regenerate the configure script.
  # Unnecessary? But the build breaks without this.
  autoreconfPhase = ''
    pushd platforms/unix/config
    make
    popd
  '';

  # Configure with options modeled on the 'mvm' build script from the vm.
  configureScript = "platforms/unix/config/configure";
  configureFlags = [ "--without-npsqueak"
                     "--with-vmversion=5.0"
                     "--with-src=spur64src" ];
  CFLAGS = "-DPharoVM -m64 -msse2 -D_GNU_SOURCE -DCOGMTVM=0 -g -O2 -DNDEBUG -DDEBUGVM=0";
  LDFLAGS = "-Wl,-z,now";
  dontStrip = true;

  # VM sources require some patching before build.
  prePatch = ''
    patchShebangs build.linux64x64
    # Fix hard-coded path to /bin/rm in a script
    sed -i -e 's:/bin/rm:rm:' platforms/unix/config/mkmf
    # Fill in mandatory metadata about the VM source version
    sed -i -e 's!\$Date\$!$Date: ${source-date} $!' \
           -e 's!\$Rev\$!$Rev: ${version} $!' \
           -e 's!\$URL\$!$URL: ${source-url} $!' \
           platforms/Cross/vm/sqSCCSVersion.h
  '';

  # Note: --with-vmcfg configure option is broken so copy plugin specs to ./
  preConfigure = ''
    cp build.linux64x64/pharo.cog.spur/plugins.{ext,int} .
  '';

  # (No special build phase.)

  installPhase = ''
    # Install in working directory and then copy
    make install-squeak install-plugins prefix=$(pwd)/products

    # Copy binaries & rename from 'squeak' to 'pharo'
    mkdir -p "$out"
    cp products/lib/squeak/5.0-*/squeak "$out/pharo"
    cp -r products/lib/squeak/5.0-*/*.so "$out"
    ln -s "${pharo-share}/lib/"*.sources "$out"

    # Create a shell script to run the VM in the proper environment.
    #
    # These wrapper puts all relevant libraries into the
    # LD_LIBRARY_PATH. This is important because various C code in the VM
    # and Smalltalk code in the image will search for them there.
    mkdir -p "$out/bin"

    # Note: include ELF rpath in LD_LIBRARY_PATH for finding libc.
    libs=$out:$(patchelf --print-rpath "$out/pharo"):${stdenv.lib.makeLibraryPath libs}

    # Create the script
    cat > "$out/bin/pharo" <<EOF
    #!/bin/sh
    set -f
    LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:$libs" exec $out/pharo "\$@"
    EOF
    sed -e 's;exec ;${gdb}/bin/gdb ;' < $out/bin/pharo > $out/bin/pharo.gdb
    chmod +x $out/bin/pharo*
    ln -s ${libgit2}/lib/libgit2.so* "$out/"
  '';

  enableParallelBuilding = true;

  # gcc 4.8 used for the build:
  #
  # gcc5 crashes during compilation; gcc >= 4.9 produces a
  # binary that crashes when forking a child process. See:
  # http://forum.world.st/OSProcess-fork-issue-with-Debian-built-VM-td4947326.html
  #
  # (stack protection is disabled above for gcc 4.8 compatibility.)
  nativeBuildInputs = [ bash unzip glibc openssl gcc5 ] ++ libs;
}
