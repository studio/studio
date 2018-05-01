# raptorjit nix library API:
#
#   raptorjit.run <luaString>:
#   raptorjit.runFile <path>:
#   raptorjit.runTarball <url>:
#   raptorjit.runDirectory <path>:
#
#     Evaluate Lua code and provide a Studio product.
#     Evaluate a Lua source file. Provide its output and the trace
#     data produced during execution.
#
#   raptorjit.evalString <luaSource>:
#     Helper function to call evalFile with code in string.

{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with builtins; with stdenv;

rec {
  raptorjit = stdenv.mkDerivation {
    name = "raptorjit-auditlog";
    nativeBuildInputs = [ gcc luajit ];
    src = fetchFromGitHub {
      owner = "lukego";
      repo = "raptorjit";
      rev = "9a798d7baff0e6e17c8cb0638e08f8f5e758448f";
      sha256 = "112a1f38c50gs8ichjdb4phkywa5l664f2jl6aiv45vgq8iarlh0";
    };
    installPhase = ''
      install -D src/raptorjit $out/bin/raptorjit
    '';
    enableParallelBuilding = true;  # Do 'make -j'
    dontStrip = true;
  };
  evalTarball = url: evalCode (fetchTarball url);
  evalCode = source:
    runCommand "raptorjit-eval-code"
    {
      src = source;
      nativeBuildInputs = [ raptorjit ];
      dontStrip = true;
    }
    ''
      mkdir $out
      if [ -d $src ]; then
          cp -r $src/* .
      else
          cp $src ./
      fi
      raptorjit -p initial.vmprofile -a audit.log *.lua 2>&1 | tee $out/output.txt
      if [ -f audit.log ]; then
        cp audit.log $out/
      fi
      mkdir -p $out/vmprofile
      find . -name '*.vmprofile' -exec cp {} $out/vmprofile \;
    '';
  inspect = jit:
      runCommand "inspect" {
        inherit jit;
      }
      ''
        mkdir -p $out/.studio
        mkdir $out/vmprofile
        cat > $out/.studio/product-info.yaml <<EOF
        type: raptorjit
        EOF
        if [ -d $jit ]; then
          find $jit -name audit.log -exec cp -n {} $out/audit.log \;
          find $jit -name '*.vmprofile' -exec cp {} $out/vmprofile/ \;
        else
          # assume it's an audit.log file
          cp $jit $out/audit.log
        fi
      '';
  # Run RaptorJIT code and product a Studio product.
  runCode = fileOrDirectory:
    rec {
      raw = evalCode fileOrDirectory;
      product = inspect raw;
    };
  # Convenience wrappers
  run = luaSource: runCode (writeTextDir "script.lua" luaSource);
  runTarball = url: runCode (fetchTarball url);
  runFile = runCode;
  runDirectory = runCode;
}
