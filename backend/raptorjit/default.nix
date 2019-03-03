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
      rev = "31d41be63097103ba7dd7881a73ff390ee18b9be";
      sha256 = "00q4zny0vp4lz3lw3q5n09w4a4dwhgawpll9jd61bs737pkv0wxf";
    };
    installPhase = ''
      install -D src/raptorjit $out/bin/raptorjit
    '';
    enableParallelBuilding = true;  # Do 'make -j'
    dontStrip = true;
  };
  # Like fetchTarball but more robust/forgiving of broken symlinks
  getTarball = url:
    runCommand "gettarball" { src = fetchurl url; } ''
      mkdir $out
      cd $out
      tar xf $src
    '';
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
  # Run RaptorJIT code and product a Studio product.
  runCode = fileOrDirectory:
    rec {
      raw = evalCode fileOrDirectory;
      product = raw;
    };
  # Convenience wrappers
  run = luaSource: runCode (writeTextDir "script.lua" luaSource);
  runTarball = url: runCode (getTarball url);
  runFile = runCode;
  runDirectory = runCode;
  inspectUrl = url: getTarball url;
}
