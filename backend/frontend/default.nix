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
    version = "25";
    url = "https://ci.inria.fr/pharo-contribution/job/Studio/default/${version}/artifact/Studio.zip";
    sha256 = "0kc938mz4b37jbl2994ch3ln8sbdaa797333f49sgb1glx83ny90";
  };

  # Script to update and customize the image for Studio.
  loadSmalltalkScript = writeScript "studio-load-smalltalk-script.st" ''
    | repo window |

    "Force reload of all Studio packages from local sources."
    repo := MCFileTreeRepository new directory: '${../../frontend}' asFileReference.
    repo allFileNames do: [ :file |
        Transcript show: 'Loading: ', file; cr.
        (repo versionFromFileNamed: file) load.
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
    { nativeBuildInputs = [ pharo ]; }
    ''
      cp ${base-image}/* .
      chmod +w pharo.image
      chmod +w pharo.changes
      pharo --nodisplay pharo.image st --quit ${loadSmalltalkScript}
      mkdir $out
      cp new.image $out/pharo.image
      cp new.changes $out/pharo.changes
    '';

  studio-inspector-screenshot = { name, object, view, width ? 640, height ? 480 }:
    runCommand "studio-screenshot-${name}.png"
      {
        nativeBuildInputs = [ pharo ];
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
        pharo --nodisplay pharo.image st --quit $smalltalkScript
        mkdir $out
        cp screenshot.png $out/${name}.png
      '';

  # Script to start the Studio image with the Pharo VM.
  studio-x11 = writeTextFile {
    name = "studio-x11-${studio-version}";
    destination = "/bin/studio-x11";
    executable = true;
    text = ''
      #!${stdenv.shell}
      cp ${studio-image}/pharo.image pharo.image
      cp ${studio-image}/pharo.changes pharo.changes
      chmod +w pharo.image
      chmod +w pharo.changes
      export STUDIO_PATH=''${STUDIO_PATH:-${../..}}
      ${pharo}/bin/pharo pharo.image
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
        (Smalltalk imageDirectory / 'studio-test.png') asFileReference delete.
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
        cp ${studio-image}/* .
        chmod +x pharo.image pharo.changes
        timeout 30 \
          ${pharo}/bin/pharo --nodisplay pharo.image st --quit ${studio-test-script}
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

