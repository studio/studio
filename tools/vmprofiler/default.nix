# vmprofiler nix library API:
#
#   vmprofiler.analyze_dir <directory>:
#     Analyze a directory containing vmprofile data.
#     Creates summary files (text and csv.)
#
#   NYI: vmprofiler.analyze_shm <shm-tarball>:
#     Analyze a Snabb shm tarball.
#     (This runs analyze_dir on $shm/engine/vmprofile.)
{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv;

let buildInputs = with rPackages; [ R dplyr bit64 tibble purrr readr stringr ];
in

{
  analyze_dir = dir: runCommand "vmprofiler-summary" { inherit buildInputs; } ''
    mkdir $out
    Rscript - <<EOF
      source("${./vmprofiler.R}")
      summarize_vmprofile("${dir}", "$out")
    EOF
  '';
}
