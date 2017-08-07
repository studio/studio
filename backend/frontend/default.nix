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
    version = "19";
    url = "https://ci.inria.fr/pharo-contribution/job/Studio/default/${version}/artifact/Studio.zip";
    sha256 = "19jhw0fnca4450a7iv51mzq91wixm5gllq7qwnw9r4yxhnkm3vak";
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

  studio-inspector-screenshot = { name, object, width ? 800, height ? 600 }:
    runCommand "studio-screenshot-${name}.png"
      {
        nativeBuildInputs = [ pharo ];
        smalltalkScript = writeScript "studio-screenshot.st"
          ''
            | __window __object __morph |
            Transcript show: 'Taking screenshot'; cr.
            "Create the object."
            __object := [
              ${object}
            ] value.
            "Create the inspector."
            __window := GTInspector inspector: __object.
            __window width: ${toString width}; height: ${toString height}.
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
in
  
{
  # main package collection for 'nix-env -i'
  studio = { inherit studio-x11 studio-vnc tigervnc; };
  # individual packages
  studio-gui = studio-x11;           # deprecated
  studio-gui-vnc = studio-vnc;       # deprecated
  studio-base-image = base-image;
  studio-image = studio-image;
  inherit studio-inspector-screenshot;
}

