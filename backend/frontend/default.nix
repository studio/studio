{ pkgs }:
with pkgs; with stdenv; with lib;

let studio-version = import ../../nix/studio-version.nix; in

#
# Currently we build the Studio Pharo frontend by packaging the
# binaries built and distributed by Feenk for GToolkit.
#
# Specifically we package the VM, libraries, and bare image built by
# their CI.
#
# We don't package their main release because it mixes all these
# pieces together and comes with a graphical image that doesn't start
# easily inside a Nix build sandbox (tries to do X11/OpenGL stuff on
# startup.)
#
# We don't build from source mostly because the Skia graphics library
# is a Rust library that requires more Rust build support than I could
# find for nixpkgs at the moment.
#
# Maybe we should build the Smalltalk VM ourselves like we used to?
# Feenk have a fork on Github that we could try.
#

let
  # Dependencies for Pharo/GToolkit.
  deps = [
      fontconfig
      freetype
      gdk_pixbuf
      glib
      gtk3
      gtk3-x11
      gtk2
      libGL
      libpulseaudio
      mesa
      mesa.drivers
      mesa.osmesa
      libGLU
      libGL_driver
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXt
      xorg.libxcb
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
    ];

  gt-version = "v0.8.407";

  gt-lib = mkDerivation {
    name = "gt-lib-${gt-version}";
    src = fetchzip {
      url = "https://github.com/feenkcom/gtoolkit/releases/download/${gt-version}/libLinux64.zip";
      sha256 = "1x537pf10w71k82dmax9bdxhsky6r20c4g21kzz296nfpqj4x6y9";
    };
    buildInputs = deps;
    nativeBuildInputs = [ autoPatchelfHook ];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/lib
      cp *.so $out/lib
    '';
  };

  gt-bin = mkDerivation {
    name = "gt-bin-${gt-version}";
    buildInputs = deps ++ [ gt-lib ];
    nativeBuildInputs = [ autoPatchelfHook ];
    src = fetchzip {
      url = "https://github.com/feenkcom/gtoolkit/releases/download/${gt-version}/GlamorousToolkitVM-linux64-bin.zip";
      sha256 = "18lvx6mr5cjhlaw63rr6cd43n1b0nvwvicnr4ha038fa4z7r4fkw";
      stripRoot = false;
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir $out
      cp -a * $out/
      ln -s ${mesa.drivers}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
    '';
  };

  gt-image = fetchzip {
    name = "gt-image-${gt-version}";
    url = "https://github.com/feenkcom/gtoolkit/releases/download/${gt-version}/GT.zip";
    sha256 = "1bvaqij1x93wgk6q9hpc3zz1fvh1fss8nar0dxjc5kyiwklynfjv";
  };


  gt-pharo = writeScriptBin "pharo" ''
    #!${shell}
    LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:${makeLibraryPath ([ gt-bin gt-lib ] ++ deps)}" \
      exec ${gt-bin}/lib/glamoroustoolkit "$@"
  '';

  # Script to update and customize the image for Studio.
  loadSmalltalkScript = writeScript "studio-load-smalltalk-script.st" ''
    | repo window |

    "Force reload of all Studio packages from local sources."
    Transcript show: 'Finding repo'; cr.
    repo := '${../../frontend}' asFileReference.

    Transcript show: 'Loading StudioLoader..'; cr.
    (TonelReader on: repo fileName: #'Studio-Loader') version load.

    Transcript show: 'Loading all Studio packages..'; cr.
    StudioLoader new loadAllStudioPackagesFrom: repo.

    Transcript show: 'Saving image to disk..'; cr.
    (Smalltalk saveAs: 'studio')
      ifTrue: [
        "Run in resumed image on startup."
	GtInspector openOn:
          (GtDocumenter forFile: Studio dir / 'doc' / 'Studio.pillar').
      ].

    Transcript show: 'Done.'; cr.
  '';

  gt-test = runCommand "x"
    { nativeBuildInputs = [ gt-pharo ]; }
    ''
      cp -a ${gt-image}/* .
      chmod +w *.changes
      export HOME=$(pwd)
      pharo GlamorousToolkit.image st --quit ${loadSmalltalkScript}
      mkdir $out
      cp -a *.sources gt-extra studio.image studio.changes $out
      ln -s ${gt-pharo}/bin/pharo $out/pharo
    '';

  studio-image = gt-test;

  # Get a read-write copy of the Pharo image.
  studio-get-image = writeTextFile {
    name = "studio-get-image";
    destination = "/bin/studio-get-image";
    executable = true;
    text = ''
      #!${stdenv.shell}
      version=$(basename ${studio-image})
      cp ${studio-image}/*.image pharo-$version.image
      cp ${studio-image}/*.changes pharo-$version.changes
      chmod +w pharo-$version.image
      chmod +w pharo-$version.changes
      cp ${studio-image}/*.sources .
      realpath "pharo-$version.image"
    '';
  };

  # Script to start the Studio image with the Pharo VM.
  studio-x11 = writeTextFile {
    name = "studio-x11-${studio-version}";
    destination = "/bin/studio-x11";
    executable = true;
    text = ''
      #!${stdenv.shell}
      set -x
      image=$(${studio-get-image}/bin/studio-get-image)
      ${gt-pharo}/bin/pharo $image --no-quit --interactive "$@"
    '';
  };

  #
  # Separately package the standard release of GToolkit without
  # Studio. This can be handy for testing and experimenting.
  #

  gtoolkit-full = fetchzip {
    name = "gtoolkit-${gt-version}";
    url = "https://dl.feenk.com/gt/GlamorousToolkitLinux64-${gt-version}.zip";
    sha256 = "1nccja0rpxz4b5s447d3vl93x119fif097ln4sg7wzg29s6qhqs0";
   };

  # Script to start the standard GToolkit image.
  studio-gtoolkit = writeTextFile {
    name = "studio-gtoolkit-${studio-version}";
    destination = "/bin/studio-gtoolkit";
    executable = true;
    text = ''
      #!${stdenv.shell}
      set -e
      set -x
      tmp=$(mktemp -d)
      echo "tmp = $tmp"
      cp -r ${gtoolkit} $tmp
      chmod -R a+w $tmp
      cd $tmp/*
      echo $DISPLAY
      ${gt-pharo}/bin/pharo GlamorousToolkit.image --no-quit --interactive "\$@"
    '';
  };

  # Configuration file to make ratpoison run Studio.
  ratpoisonConfig = writeScript "studio-ratpoison-config"
    ''
      escape F1
      exec ${studio-x11}/bin/studio-x11
    '';

  # Script to run ratpoison with the config for Studio.
  ratpoisonScript = writeScript "studio-ratpoison"
    ''
      #!${stdenv.shell}
      exec ${ratpoison}/bin/ratpoison -f ${ratpoisonConfig}
    '';

  # Pharo spews some unhelpful error messages. Suppress them.
  filterPharoOutput = "| (egrep -v -e '^warning:' -e ': GLib-' -e 'pthread_setschedparam failed: Operation not permitted')";

  # Script to run everything in VNC.
  studio-vnc = writeTextFile {
    name = "studio-vnc-${studio-version}";
    destination = "/bin/studio-vnc";
    executable = true;
    text = ''
      #!${stdenv.shell}
      exec ${tigervnc}/bin/vncserver \
        "$@" \
        -name "Studio" \
        -fg \
        -autokill \
        -xstartup ${ratpoisonScript} \
        -SecurityTypes None
    '';
  };

  studio-test =
    # Script to do a simple test of the GUI.
    let studio-test-script = writeScript "studio-test-script.st" ''
        Transcript show: 'Exercising the Studio UI..'; cr.
        RaptorJIT test.
        Transcript show: 'Finished.'; cr.
      ''; in
     writeTextFile {
      name = "studio-test-${studio-version}";
      destination = "/bin/studio-test";
      executable = true;
      text = ''
        #!${stdenv.shell}
        image=$(${studio-get-image}/bin/studio-get-image)
        timeout 600 ${xvfb_run}/bin/xvfb-run \
          ${gt-pharo}/bin/pharo --nodisplay $image st --quit ${studio-test-script}
      '';
  };

  studio-decode =
    # Script to decode binary data into a more usable format.
    let studio-decode-script = writeScript "studio-decode-script.st" ''
        | env input output |
        env := OSProcess thisOSProcess environment.
        input := (env at: #STUDIO_DECODE_INPUT) asFileReference.
        output := (env at: #STUDIO_DECODE_OUTPUT) asFileReference.
        Transcript show: 'Studio decoding from ', input printString, ' to ', output printString; cr.
        Studio decodeFrom: input to: output.
        Transcript show: 'Finished.'; cr.
      ''; in
      writeTextFile {
        name = "studio-decode-${studio-version}";
        destination = "/bin/studio-decode";
        executable = true;
        text = ''
          #!${stdenv.shell}
          if [ $# != 2 ]; then
            echo "usage: <input> <output>"
            exit 1
          fi
          export STUDIO_DECODE_INPUT=$1
          export STUDIO_DECODE_OUTPUT=$2
          image=$(${studio-get-image}/bin/studio-get-image)
          timeout 600 ${xvfb_run}/bin/xvfb-run \
            ${gt-pharo}/bin/pharo --nodisplay $image st --quit ${studio-decode-script} ${filterPharoOutput}
        '';
  };
  # Environment for nix-shell
  studio-env = runCommand "studio" {
      buildInputs = [ nixUnstable xorg.xauth perl disasm xvfb_run cacert
                      binutils gnugrep
                      dwarfish.binutils
                      studio-x11 studio-vnc studio-test studio-decode studio-gtoolkit ];
    } "echo ok > $out";

in
  
{
  # main package collection for 'nix-env -i'
  studio = { inherit studio-x11 studio-vnc studio-gtoolkit studio-test studio-decode tigervnc; };
  # individual packages
  studio-gui = studio-x11;           # deprecated
  studio-gui-vnc = studio-vnc;       # deprecated
  studio-image = studio-image;
  studio-env = studio-env;
  inherit studio-inspector-screenshot;
  inherit studio-x11 studio-vnc studio-gtoolkit studio-test studio-decode;
  inherit gt-test;
}

