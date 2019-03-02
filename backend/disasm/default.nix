{ pkgs }:
with pkgs; with stdenv;

writeScriptBin "disasm" ''
  #!/usr/bin/env bash
  set -e

  [ $# == 2 ] || (echo "Usage: disasm <file> <startaddress>"; exit 1)
  file="$1"
  start="$2"

  objdump -mi386 -M intel -M intel-mnemonic -M x86-64 \
          --adjust-vma=$start \
          --no-show-raw-insn \
          -D -b binary "$file" \
    | grep -E '^ *[0-9a-fA-F]+:'
''
