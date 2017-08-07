{ nixpkgs }:
{ studio-manual-html = import ./default.nix (nixpkgs { overlays = import ../overlays.nix; }) }
