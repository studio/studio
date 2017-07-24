# raptorjit nix library API:
#
#   raptorjit.evalFile <luaSourceFile>:
#     Evaluate a Lua source file. Provide its output and the trace
#     data produced during execution.
#
#   raptorjit.evalString <luaSource>:
#     Helper function to call evalFile with code in string.

{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv;

let
  raptorjit = llvmPackages_4.stdenv.mkDerivation {
    name = "raptorjit-auditlog";
    nativeBuildInputs = [ gcc luajit ];
    src = fetchFromGitHub {
      owner = "raptorjit";
      repo = "raptorjit";
      rev = "89407be06213d8e0d43133c014e5c6607b66bd8d";
      sha256 = "1a3y7079kbwqv0x6zjz2jq5fbpv7qfcfq70kz9p11cy12pj0dpg9";
    };
    installPhase = ''
      install -D src/luajit $out/bin/raptorjit
      install -D src/lj_dwarf.dwo $out/lib/raptorjit.dwo
    '';
    enableParallelBuilding = true;  # Do 'make -j'
  };
in

rec {
  evalFile = luaSourceFile:
    runCommand "raptorjit-eval" { nativeBuildInputs = [ raptorjit ]; } ''
      mkdir $out
      raptorjit ${luaSourceFile} 2>&1 | tee $out/output.txt
      cp ${raptorjit}/lib/raptorjit.dwo $out/
      if [ -f audit.log ]; then
        cp audit.log $out/
      fi
    '';
  evalString = luaSource:
    evalFile (writeScript "eval-source.lua" luaSource);
}
