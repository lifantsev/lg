# lg

A simple script for reading and writing log files.

## Usage

### Logging

To enable logging, `$LGENABLE` must be set to 1 (If set to 0 or unset, `lg` will do nothing and exit successfully). `$LGSTEM` must be set to the name of the program that is logging (this determines which file logs are written to). You may optionally set `$LGSPEC` to a specifier like `ui` or `backend`, to distinguish log lines that are sent to the same file.

``` sh
lg start
lg . "quick info update"
lg F "function_x was called"
lg I "important info here"
lg finish
```

The start and finish commands create a much shorter line and thus create visual breaks in the log file. Any other log must have a log level (arg 1) and a log string (arg 2). These types of logs include a timestamp in the logfile. There is a special log level `E`, which will cause logs to be written not only to the logfile but also to stdout:
``` sh
lg E "expected A but got B" # warning: this will write to stdout
```

Logs are written to `$XDG_STATE_HOME/logs/`.

### Viewing

This script also exposes some options to allow users to easily manipulate log files:
``` sh
lg "view"  program # opens the logfile for `program` using less
lg "tail"  program # prints last 20 lines
lg "watch" program # uses `watch` to continuously show the last 50 lines
lg "clear" program # clears the log file
lg "clear" all # clears all log files in $XDG_STATE_HOME/logs
```

## Installation

### Nix Flake

Nix flake users can just add this flake as an input:
``` nix
# flake.nix
inputs.lg.url = "github:lifantsev/lg";
```

Then install the package:
``` nix
# configuration.nix
environment.systemPackages = [ inputs.lg.packages.${system}.default ];

# or home.nix
home.packages = [ inputs.lg.packages.${system}.default ];
```

You may alternatively use an overlay to add `lg` to the `pkgs` attribute set:
``` nix
# flake.nix
outputs.nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem.modules = [{
    nixpkgs.overlays = [(final: prev: {
        lg = inputs.lg.packages.${system}.default;
    })]
}]

# then in configuration.nix
environment.systemPackages = [ pkgs.lg ];
```

### Otherwise

Download the [shellscript](lg.sh), add a shebang, and install it however you usually would.
