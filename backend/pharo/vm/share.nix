{ stdenv, fetchurl, unzip, runCommand }:

runCommand "pharo-share-1.0" { buildInputs = [ unzip ]; }
  ''
    mkdir -p $out/lib
    cp ${./sources}/Pharo7.0-32bit-14a515b.sources $out/lib/
    cp ${./sources}/Pharo7.0-32bit-362a6cd.sources} $out/lib/
  ''
