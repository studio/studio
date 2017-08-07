{ nixpkgs }:
{ studio-manual-html = import ./default.nix { pkgs = (nixpkgs { overlays = import ../overlays.nix; }); } }
