{ stdenv, fetchurl, unzip, runCommand }:

runCommand "pharo-share-1.0"
  rec {
    sources60Zip = fetchurl {
      url = http://files.pharo.org/sources/PharoV60.sources.zip;
      sha256 = "0xbdi679ryb2zg412xy6zkh22l20pmbl92m3qhfgzjvgybna8z2a";
    };

    buildInputs = [ unzip ];
  }
  ''
    mkdir -p $out/lib
    unzip $sources60Zip -d $out/lib/
  ''
