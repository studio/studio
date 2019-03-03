# Dwarfish is a library for extracting type information from DWARF
# debug information in ELF files.
#
# dwarfish nix library API:
#
#   dwarfish.elf2text <elfFile>:
#   dwarfish.elf2yaml <elfFile>:
#   dwarfish.elf2json <elfFile>:
#     Export DWARF type information from an ELF file into various formats.

{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv; with pythonPackages;

let readelf = mkDerivation {
                name = "binutils";
                src = fetchurl {
                  url = "mirror://gnu/binutils/binutils-2.31.1.tar.gz";
                  sha256 = "126yip8wmvrg1rw4k018qrx8spz337c8il2ab9vd6x8aplv8v3z8";
                };
              };
in

rec {
  elf2text = elf: runCommand "dwarftext" { inherit elf; } ''
    set +e
    ${readelf}/bin/readelf -W --debug-dump=info,macro $elf > $out
  '';
  elf2yaml = elf: runCommand "dwarfyaml" { text = elf2text elf;
                                           buildInputs = [ gawk ]; } ''
    awk -f ${./dwarf2yaml.awk} < $text > $out
  '';
  elf2json = elf: runCommand "dwarfjson" { yaml = elf2yaml elf;
                                           buildInputs = [ python pyyaml ]; } ''
    python ${./yaml2json.py} < $yaml > $out
  '';
  binutils = readelf;
}

