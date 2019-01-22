{ pkgs }:
with pkgs; with stdenv;

let studio-version = import ../../nix/studio-version.nix; in

let
  # Function to fetch a Pharo image from a zip file.
  fetchImageZip = { name, version, url, sha256 }:
    mkDerivation {
      inherit name version;
      sourceRoot = ".";
      src = fetchurl {
        inherit url sha256;
      };
      nativeBuildInputs = [ unzip ];
      installPhase = ''
        mkdir $out
        cp *.image $out/pharo.image
        cp *.changes $out/pharo.changes
      '';
    };

  # Pharo image that includes all external dependencies.
  # Built on Inria CI (Jenkins) with Metacello to install Studio.
  base-image = fetchImageZip rec {
    name = "studio-base-image-${version}";
    version = "32";
    url = "https://ci.inria.fr/pharo-contribution/job/Studio/default/${version}/artifact/Studio.zip";
    sha256 = "08hjh3qldh5h1rgjk9pqx56d2zwn34j79gh44d9vcgw8vxvdkgaz";
  };

  pharo70rc1-image = fetchImageZip rec {
    name = "pharo70rc1-image";
    version = "70rc1";
    url = "http://files.pharo.org/image/70/Pharo7.0.0-rc1.build.1435.sha.4cd23cf.arch.64bit.zip";
    sha256 = "1qkgycdw2kr63cihghfa7kiabg64j75a4ccdpzvmxnw0amnnxwn3";
  };

  handmade-gt-image = ./Studio-base.zip;

  # Script to update and customize the image for Studio.
  loadSmalltalkScript = writeScript "studio-load-smalltalk-script.st" ''
    | repo window |

    "Disable cache to prevent access to path that is not available."
    MCCacheRepository uniqueInstance disable.

    "Force reload of all Studio packages from local sources."
    repo := '${../../frontend}' asFileReference.
    (FileSystem disk childrenAt: repo) do: [ :path |
      | packageName reader |
      path asFileReference entries ifNotEmpty: [
        packageName := path basenameWithoutExtension.
        Transcript show: 'Loading package: ', packageName; cr.
        reader := (TonelReader on: repo fileName: packageName).
        reader version load. ].
      ].

    "Load additional patches to the image."
    '${./patches}' asFileReference entries do: [ :entry |
        Transcript show: 'Patching: ', entry asFileReference fullName; cr.
        entry asFileReference fileIn. ].

    "Setup desktop"
    Pharo3Theme beCurrent. "light theme"
    World closeAllWindowsDiscardingChanges.
    StudioInspector open openFullscreen.

    "Save image"
    Smalltalk saveAs: 'new'.
  '';

  # Studio image that includes the exact code in this source tree.
  # Built by refreshing the base image.
  studio-image = runCommand "studio-image"
    { nativeBuildInputs = [ pharo unzip xvfb_run ]; }
    ''
      unzip ${handmade-gt-image}
      cp Studio.image pharo.image
      cp Studio.changes pharo.changes
      chmod +w pharo.image
      chmod +w pharo.changes
      xvfb-run pharo --nodisplay pharo.image st --quit ${loadSmalltalkScript}
      mkdir $out
      cp new.image $out/pharo.image
      cp new.changes $out/pharo.changes
    '';

  studio-inspector-screenshot = { name, object, view, width ? 640, height ? 480 }:
    runCommand "studio-screenshot-${name}.png"
      {
        nativeBuildInputs = [ pharo xvfb_run ];
        smalltalkScript = writeScript "studio-screenshot.st"
          ''
            | __window __object __morph __presentations |
            Transcript show: 'Taking screenshot'; cr.
            "Create the object."
            __object := [
              ${object}
            ] value.

            "Create the inspector."
            __window := GTInspector inspector: __object.
            __window width: ${toString width}; height: ${toString height}.

            "Select the right presentation."
            __presentations := __window model panes first 
                                 presentations first cachedPresentation first.
            __presentations pane lastActivePresentation:
              (__presentations presentations detect: [ :each |
                each title = '${view}' ]).

            "Save the screenshot."
            PNGReadWriter putForm: __window imageForm
                          onFileNamed: Smalltalk imageDirectory / 'screenshot.png'.
            Transcript show: 'Took screenshot'; cr.
          '';
       }
      ''
        cp ${studio-image}/* .
        chmod +w pharo.image pharo.changes
        xvfb-run pharo --nodisplay pharo.image st --quit $smalltalkScript
        mkdir $out
        cp screenshot.png $out/${name}.png
      '';

  # Get a read-write copy of the Pharo image.
  studio-get-image = writeTextFile {
    name = "studio-get-image";
    destination = "/bin/studio-get-image";
    executable = true;
    text = ''
      #!${stdenv.shell}
      version=$(basename ${studio-image})
      cp ${studio-image}/pharo.image pharo-$version.image
      cp ${studio-image}/pharo.changes pharo-$version.changes
      chmod +w pharo-$version.image
      chmod +w pharo-$version.changes
      cp ${pharo.pharo-share}/lib/*.sources .
      echo pharo-$version.image
    '';
  };

  # Script to start the Studio image with the Pharo VM.
  studio-x11 = writeTextFile {
    name = "studio-x11-${studio-version}";
    destination = "/bin/studio-x11";
    executable = true;
    text = ''
      #!${stdenv.shell}
      export STUDIO_PATH=''${STUDIO_PATH:-${../..}}
      image=$(${studio-get-image}/bin/studio-get-image)
      ${pharo}/bin/pharo $image "$@"
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
        StudioInspector new
          go: 'with import <studio>; raptorjit.run "for i = 1, 1e8 do end"'.
        GTInspector openOn: (RJITAuditLog allInstances first) traces first irTreeView.
        Transcript show: 'Taking a screenshot..'; cr.
        [ (Smalltalk imageDirectory / 'studio-test.png') asFileReference delete ]
          on: FileDoesNotExist do: []. "Ignore."
        PNGReadWriter putForm: World imageForm
                      onFileNamed: Smalltalk imageDirectory / 'studio-test.png'.
        Transcript show: 'Took screenshot'; cr.
      ''; in
     writeTextFile {
      name = "studio-test-${studio-version}";
      destination = "/bin/studio-test";
      executable = true;
      text = ''
        #!${stdenv.shell}
        image=$(${studio-get-image}/bin/studio-get-image)
        timeout 600 ${xvfb_run}/bin/xvfb-run \
          ${pharo}/bin/pharo --nodisplay $image st --quit ${studio-test-script}
      '';
  };
in
  
{
  # main package collection for 'nix-env -i'
  studio = { inherit studio-x11 studio-vnc studio-test tigervnc; };
  # individual packages
  studio-gui = studio-x11;           # deprecated
  studio-gui-vnc = studio-vnc;       # deprecated
  studio-base-image = base-image;
  studio-image = studio-image;
  inherit studio-inspector-screenshot;
  inherit studio-x11 studio-vnc studio-test;


}

