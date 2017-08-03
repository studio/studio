# Dwarfish regression tests.

{ pkgs ? (import ../../../nix/pkgs.nix) {} }:
with pkgs; with stdenv;
let buildInputs = [ diffutils ]; in
let dwarfish = import ../. {}; in

rec {
  text = dwarfish.elf2text ./raptorjit.dwo;
  yaml = dwarfish.elf2yaml ./raptorjit.dwo;
  json = dwarfish.elf2json ./raptorjit.dwo;
  check-yaml = runCommand "checkyaml" { inherit yaml buildInputs; } ''
    diff -u $yaml ${./expect.yaml} && touch $out
  '';
  check-json = runCommand "checkjson" { inherit json buildInputs; } ''
    diff -u $json ${./expect.json} && touch $out
  '';
}


