{ pkgs ? import ../../../nix/pkgs.nix {}
, what }:
with pkgs;

runCommand "hexdump" { inherit what; nativeBuildInputs = [ utillinux ]; } ''
  mkdir $out
  hexdump -C $what > $out/hexdump.txt
  echo text/hexdump > $out/.studio-type
''
