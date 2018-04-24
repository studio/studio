{ pkgs }:
with pkgs; with stdenv;

writeScriptBin "disasm" ''
  #!/usr/bin/env bash
  set -e

  [ $# == 1 ] || (echo "Usage: $0 <startaddress>"; exit 1)
  start=$1

  tmp=$(mktemp)
  trap "rm -f $tmp" EXIT

  cat > $tmp
  ${binutils}/bin/objdump -mi386 -M intel -M intel-mnemonic -M x86-64 \
          --adjust-vma=$start \
          --no-show-raw-insn \
          -D -b binary $tmp \
    | ${gnugrep}/bin/grep -E '^ *[0-9a-fA-F]+:'
''
