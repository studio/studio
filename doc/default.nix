# Studio manual
{ pkgs ? (import ../.) }:
with pkgs; with stdenv;

let screenshots = import ./screenshots.nix { inherit pkgs; }; in

runCommand "studio-manual-html" {
    src = ./.;
    buildInputs = [ pandoc ];
    template = fetchFromGitHub {
      owner = "tonyblundell";
      repo = "pandoc-bootstrap-template";
      rev = "93d238e878ace6b2ab9a948be502191dd744003f";
      sha256 = "18fhar1j5vapb51p9fy4dqcngahga1h502n2s8irn54adiz7xzzx";
    };
  }
  ''
    cp -r $src/* .
    cp $template/* .
    mkdir screenshots
    cp ${screenshots.RaptorJIT-Process-TraceOverview}/* screenshots/
    mkdir $out
    pandoc studio.md -o $out/studio.html \
      --template template.html --css template.css \
      --self-contained --toc --toc-depth 3
  ''

