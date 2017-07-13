{ pkgs ? import ../../../nix/pkgs.nix {}
, what }:
with pkgs;

runCommand "pcap2xml" { inherit what; nativeBuildInputs = [ wireshark-cli ]; } ''
  mkdir $out
  tshark -Tpdml -r $what > $out/pdl.xml
  echo text/xml/pdml > $out/.studio-type
''
