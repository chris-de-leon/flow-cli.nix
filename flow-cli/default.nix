{pkgs ? import <nixpkgs> {}}: 

let
  inherit (pkgs) stdenv;
  releases = import ./releases.nix;
  srcAttrs = releases.sources.${stdenv.hostPlatform.system};
in

stdenv.mkDerivation {
  name = "flow-cli";

  version = releases.version;
  
  src = pkgs.fetchzip {
    inherit (srcAttrs) url sha256;
  };

  installPhase = ''
    set -e
    mkdir -p $out/bin
    cp $src/flow-cli $out/bin/flow
  '';
}
