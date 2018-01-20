{ stdenv, fetchurl, fetchFromGitHub, bash, unzip, glibc, openssl, gcc, mesa, freetype, xorg, alsaLib, cairo, pixman, fontconfig, xlibs, libuuid, autoreconfHook, gcc48, runCommand, ... }:

with stdenv.lib;

# Build the Pharo VM
stdenv.mkDerivation rec {
  name = "pharo";
  version = "git.${revision}";
  src = fetchFromGitHub {
    owner = "pharo-project";
    repo = "pharo-vm";
    rev = revision;
    sha256 = "0dkiy5fq1xn2n93cwf767xz24c01ic0wfw94jk9nvn7pmcfj7m62";
  };
  patches = [
    ./0001-sqUnixHeartbeat.c-Remove-warning-about-thread-priori.patch
  ];
  # This metadata will be compiled into the VM and introspectable
  # from Smalltalk. This has been manually extracted from 'git log'.
  #
  # The build would usually generate this automatically using
  # opensmalltalk-vm/.git_filters/RevDateURL.smudge but that script
  # is too impure to run from nix.
  revision = "6a63f68a3dd4deb7c17dd2c7ac6e4dd4b0b6d937";
  source-date = "Tue May 30 19:41:27 2017 -0700.1";
  source-url  = "https://github.com/pharo-project/pharo-vm";

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
                     "--with-src=spursrc" ];
  CFLAGS = "-DPharoVM -DIMMUTABILITY=1 -msse2 -D_GNU_SOURCE -DCOGMTVM=0 -g -O2 -DNDEBUG -DDEBUGVM=0";
  LDFLAGS = "-Wl,-z,now";

  # VM sources require some patching before build.
  prePatch = ''
    patchShebangs build.linux32x86
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
    cp build.linux32x86/pharo.cog.spur/plugins.{ext,int} .
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
    libs=$out:$(patchelf --print-rpath "$out/pharo"):${getLib cairo}/lib:${getLib pixman}/lib:${getLib fontconfig}/lib:${getLib xlibs.libxcb}/lib:${getLib xlibs.libXrender}/lib:${getLib mesa}/lib:${getLib freetype}/lib:${getLib openssl}/lib:${getLib libuuid}/lib:${getLib alsaLib}/lib:${getLib xorg.libICE}/lib:${getLib xorg.libSM}/lib

    # Create the script
    cat > "$out/bin/pharo" <<EOF
    #!/bin/sh
    set -f
    LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:$libs" exec $out/pharo "\$@"
    EOF
    chmod +x "$out/bin/pharo"
  '';

  enableParallelBuilding = true;

  # gcc 4.8 used for the build:
  #
  # gcc5 crashes during compilation; gcc >= 4.9 produces a
  # binary that crashes when forking a child process. See:
  # http://forum.world.st/OSProcess-fork-issue-with-Debian-built-VM-td4947326.html
  #
  # (stack protection is disabled above for gcc 4.8 compatibility.)
  nativeBuildInputs = [ bash unzip glibc openssl gcc48 mesa freetype xorg.libX11 xorg.libICE xorg.libSM alsaLib cairo pixman fontconfig xlibs.libxcb xlibs.libXrender pharo-share libuuid autoreconfHook ];
}
