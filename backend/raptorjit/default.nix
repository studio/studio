# raptorjit nix library API:
#
#   raptorjit.evalFile <luaSourceFile>:
#     Evaluate a Lua source file. Provide its output and the trace
#     data produced during execution.
#
#   raptorjit.evalString <luaSource>:
#     Helper function to call evalFile with code in string.

{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with builtins; with stdenv;

rec {
  raptorjit = llvmPackages_4.stdenv.mkDerivation {
    name = "raptorjit-auditlog";
    nativeBuildInputs = [ gcc luajit ];
    src = fetchFromGitHub {
      owner = "lukego";
      repo = "raptorjit";
      rev = "48be21833bb1a1897b764dd38ab30f0c18a5fbae";
      sha256 = "1gl88paqi8zxgkkz9kfcbw44v03zjql8r2mk8045fh1ldxpcjhj5";
    };
    installPhase = ''
      install -D src/raptorjit $out/bin/raptorjit
      install -D src/lj_dwarf.dwo $out/lib/raptorjit.dwo
    '';
    enableParallelBuilding = true;  # Do 'make -j'
    dontStrip = true;
  };
  evalFile = luaSourceFile:
    runCommand "raptorjit-eval"
      {
        nativeBuildInputs = [ raptorjit ];
        dontStrip = true;
      }
      ''
        mkdir $out
        raptorjit ${luaSourceFile} 2>&1 | tee $out/output.txt
        cp ${raptorjit}/lib/raptorjit.dwo $out/
        if [ -f audit.log ]; then
          cp audit.log $out/
        fi
      '';
  evalTarball = url:
    runCommand "raptorjit-eval-tarball"
    {
      src = fetchTarball url;
      nativeBuildInputs = [ raptorjit ];
      dontStrip = true;
    }
    ''
      set -x
      mkdir $out
      find $src
      cp -r $src/* .
      raptorjit *.lua 2>&1 | tee $out/output.txt
      mkdir -p $out/vmprofile
      cp ${raptorjit}/lib/raptorjit.dwo $out/
      find . -name '*.vmprofile' -exec cp {} $out/vmprofile \;
        if [ -f audit.log ]; then
          cp audit.log $out/
        fi
    '';
  evalString = luaSource:
    evalFile (writeScript "eval-source.lua" luaSource);
  inspect = jit:
    runCommand "inspect" {
        inherit jit;
        dwarfjson = dwarfish.elf2json (toPath "${jit}/raptorjit.dwo");
      }
      ''
        mkdir -p $out/.studio
        cat > $out/.studio/product-info.yaml <<EOF
        type: raptorjit
        EOF
        cp -r $jit/* $out/
        cp $dwarfjson $out/raptorjit-dwarf.json
      '';
  run = luaSource:
    rec {
      raw = evalString luaSource;
      product = inspect raw;
    };
  runTarball = url:
    rec {
      raw = evalTarball url;
      product = inspect raw;
    };
}
