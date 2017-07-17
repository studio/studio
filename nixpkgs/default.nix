let overlays = import ./overlays.nix;
    # base on nixpkgs release-17.03 from 15-07-2016.
    nixpkgs = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/8e75b4dc7b1553026c70d95a34c408dabb852943.tar.gz);
in
nixpkgs { overlays = overlays; }

