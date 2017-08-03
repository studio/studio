{ pkgs }:
with pkgs; with stdenv;

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
  baseImage = fetchImageZip rec {
    name = "studio-${version}";
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
  studioImage = runCommand "studio-image"
    { nativeBuildInputs = [ pharo ]; }
    ''
      cp ${baseImage}/* .
      chmod +w pharo.image
      chmod +w pharo.changes
      pharo --nodisplay pharo.image st --quit ${loadSmalltalkScript}
      mkdir $out
      cp new.image $out/pharo.image
      cp new.changes $out/pharo.changes
    '';

  # Script to start the Studio image with the Pharo VM.
  studioScript = writeScript "studio-gui" ''
    #!${stdenv.shell}
    cp ${studioImage}/pharo.image pharo.image
    cp ${studioImage}/pharo.changes pharo.changes
    chmod +w pharo.image
    chmod +w pharo.changes
    export STUDIO_PATH=''${STUDIO_PATH:-${../..}}
    ${pharo}/bin/pharo pharo.image
  '';

  # Configuration file to make ratpoison run Studio.
  ratpoisonConfig = writeScript "studio-ratpoison-config" ''
    escape F1
    exec ${studioScript}
  '';

  # Script to run ratpoison with the config for Studio.
  ratpoisonScript = writeScript "studio-ratpoison" ''
    #!${stdenv.shell}
    exec ${ratpoison}/bin/ratpoison -f ${ratpoisonConfig}
  '';

  # Script to run everything in VNC.
  vncScript = writeScriptBin "studio-gui-vnc" ''
    #!${stdenv.shell}
    if [ $# == 0 ]; then
      display=1
    elif [ $# == 1 ]; then
      display=$1
    fi
    exec ${tigervnc}/bin/vncserver :$display \
      -name "Studio (:$display)" \
      -fg \
      -autokill \
      -xstartup ${ratpoisonScript} \
      -SecurityTypes None
  '';
in
  
{
  studio-gui = studioScript;
  studio-gui-vnc = vncScript;
  studio-base-image = baseImage;
  studio-image = studioImage;
}

