{ pkgs ? import ../../../nix/pkgs.nix {}
, what }:
with pkgs;

let vmprofiler = import ../../../tools/vmprofiler { inherit pkgs; }; in

vmprofiler.analyze_dir what
