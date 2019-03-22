# nix-shell to reference relevant nixpkgs packages.
with import ./pkgs.nix {};

# Environment for nix-shell excluding Studio's own code.
runCommandNoCC "studio" {
  buildInputs = [ nixUnstable xorg.xauth perl xvfb_run binutils gnugrep unzip ];
} "echo ok > $out"
