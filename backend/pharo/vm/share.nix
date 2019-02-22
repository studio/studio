{ stdenv, fetchurl, unzip, runCommand }:

runCommand "pharo-share-1.0" { buildInputs = [ unzip ]; }
  ''
    mkdir -p $out/lib
    cp ${./sources}/*.sources $out/lib/
  ''
