# snabb nix library API:
#
#   snabb.processDirectory <path>
#   snabb.processTarball <url>
#     Process a Snabb shm folder for presentation.

{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv;

rec {
  processDirectory = dir: runCommand "snabb-directory" { inherit dir; } ''
    [ -f $dir/audit.log ] || (echo "error: ./audit.log not found" >&2; exit 1)
    cp --no-preserve=mode -r $dir $out
    cd $out
    cp ${./raptorjit-dwarf.json} raptorjit-dwarf.json
  '';
  processTarball = url: processDirectory (fetchTarball url);

}
