{
  description = "Overlay for the Flow CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.eachSystem [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        flow = import ./flow-cli { inherit pkgs; };
      in rec {
        defaultPackage = flow;
        
        apps.default = {
          type = "app";
          program = "${defaultPackage}/bin/flow";
        };
        
        devShell = with pkgs; mkShell {
          buildInputs = [
            flow
          ];
        };
      }
    ) // {
      overlay = (final: prev: rec {
        flow = final.callPackage ./flow-cli {};
      });
    };
}

