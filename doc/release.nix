{ nixpkgs }:
import ./default.nix (nixpkgs { overlays = import ../overlays.nix; })
