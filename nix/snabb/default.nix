with import <nixpkgs> {};
with stdenv; with lib;

let
  # Return the derivation to build a Snabb binary from source.
  mkSnabb = version: src:
    mkDerivation {
      name = "snabb-${version}";
      src = src;
      enableParallelBuilding = true;
      installPhase = ''
	mkdir -p $out/bin
	cp src/snabb $out/bin/
      '';
    };

  master = tag: hash:
    mkSnabb tag (fetchFromGitHub {
      owner = "snabbco"; repo = "snabb"; rev = tag; sha256 = hash;
    });

  snabbs = { master-v2016-11 = master "v2016.11" "0v9phzxi3mi8yy71p52nb5kjvqlpzx82qghb7m0skdyc4rfn470f"; };

  # Return the derivation to build LuaJIT DWARF debug info corresponding
  # with a Snabb package.
  mkDwarf = snabb:
    overrideDerivation snabb (oldAttrs:
      {
        buildInputs = [ gcc ];
	buildPhase = ''
	  cp ${./lj_dwarf.c} lib/luajit/src/lj_dwarf.c
	  pushd lib/luajit/src
	  gcc -g3 -gdwarf-4 -fno-eliminate-unused-debug-types -gsplit-dwarf \
		-c -o lj_dwarf.o lj_dwarf.c
	  popd
          objdump --dwarf --wide lib/luajit/src/lj_dwarf.dwo > luajit-dwarf.txt
        '';
	installPhase = ''
	  mkdir -p $out
	  cp luajit-dwarf.txt $out/
	'';
      });

  dwarfs = mapAttrs (name: snabb: mkDwarf snabb) snabbs;

in
dwarfs
