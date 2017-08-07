{ nixpkgs }:
let pkgs = (import nixpkgs { overlays = import ../overlays.nix; }); in
{
  studio-manual-html = import ./default.nix { inherit pkgs; };
}
  
