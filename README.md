# flow-cli.nix
<div>
  <a href="https://github.com/chris-de-leon/flow-cli.nix/actions">
		<img src="https://github.com/chris-de-leon/flow-cli.nix/actions/workflows/update-flow-cli.yml/badge.svg"/>
	</a>
</div>

## Overview

This repository contains a Nix overlay for the [Flow CLI](https://github.com/onflow/flow-cli). It is automatically updated on a daily basis (every day at midnight UTC) with the latest stable version of the CLI.

## Usage

The following commands showcase some potential uses for the Flow CLI Nix overlay. If any of the commands below don't work, you may need to run `nix-collect-garbage` to remove any older and potentially buggy versions of the overlay.

### Nix CLI

With [Nix v2.4](https://nix.dev/tutorials/install-nix) or newer, the following command can be used to invoke the latest version of the Flow CLI:

```sh
nix run github:chris-de-leon/flow-cli.nix
```

Or with a specific version:

```sh
nix run https://github.com/chris-de-leon/flow-cli.nix/archive/refs/tags/v1.8.0.tar.gz
```

We can also pass arguments to the Flow CLI as follows:

```sh
nix run github:chris-de-leon/flow-cli.nix -- version
```

Or with a specific version:

```sh
nix run https://github.com/chris-de-leon/flow-cli.nix/archive/refs/tags/v1.8.0.tar.gz -- version
```


Entering a shell with the Flow CLI binary injected follows a similar pattern:

```sh
nix develop github:chris-de-leon/flow-cli.nix
```

Or with a specific version:

```sh
nix develop https://github.com/chris-de-leon/flow-cli.nix/archive/refs/tags/v1.8.0.tar.gz
```

### Nix Development Shell

To use this overlay in a custom development shell, you can use something similar to the following:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flowcli.url = "github:chris-de-leon/flow-cli.nix";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flowcli, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ flowcli.overlay ];
        };
      in {
        devShell = with pkgs; mkShell {
          buildInputs = [
            # NOTE: you can also use flowcli.defaultPackage.${system}
            flow
          ];
        };
      });
}
```

Or with a specific version:

```nix
{
  inputs = {
    flowcli.url = "https://github.com/chris-de-leon/flow-cli.nix/archive/refs/tags/v1.8.0.tar.gz";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flowcli, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ flowcli.overlay ];
        };
      in {
        devShell = with pkgs; mkShell {
          buildInputs = [
            # NOTE: you can also use flowcli.defaultPackage.${system}
            flow
          ];
        };
      });
}
```
