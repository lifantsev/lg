# lg

A simple set of scripts for reading and writing log files.

- [lga & lge](#logging), [lg](#viewing)

## Usage

### Logging

To enable logging, `$LGENABLE` must be set to 1 (If set to 0 or unset, the script will do nothing and exit successfully). `$LGSTEM` must be set to the name of the program that is logging (this determines which file logs are written to). You may optionally set `$LGSPEC` to a specifier like `ui` or `backend`, to distinguish log lines that are sent to the same file. Finally, log lines will be colorized by their log level (first arg).

``` sh
lga start # the 'a' stands for async (this script does the log writes asynchronously)
lga . "quick info update"
lga F "function_x was called" # will print a blue line
lga I "important info here" # yellow line
lga R "returned this value" # green line
lga E "my error" # red line
lga finish
```

The start and finish commands create a much shorter line and thus create visual breaks in the log file (and finish lines contain the time delta since the last start line). Any other log must have a log level (capital letter in arg 1) and a log string (arg 2).

To log errors you may use `lga E` but there is also a provided util `lge` that will do the logging and will also print the error message to stdout:
``` sh
lge "expected A but got B" # warning: this will write to stdout
```

Logs are written to `$XDG_STATE_HOME/logs/`.

### Viewing

This script also exposes some options to allow users to easily manipulate log files:
``` sh
lg "view|v"  program # opens the logfile for `program` using less
lg "tail|t"  program # prints last 20 lines
lg "watch|w" program # uses `watch` to continuously show the last 50 lines
lg "clear|c" program # clears the log file
lg "clear|c" all # clears all log files in $XDG_STATE_HOME/logs
```

## Installation

### Nix Flake

Nix flake users can just add this flake as an input, and use the nixosModule to add `pkgs.lg` and install:
``` nix
# flake.nix
inputs.lg.url = "github:lifantsev/lg";

# configuration.nix
imports = [ inputs.lg.nixosModules.default ]; # adds pkgs.lg, pkgs.lga, and pkgs.lge (using overlays) & installs to systemPackages
```

Or install the packages manually, without the nixosModule:
``` nix
# configuration.nix
environment.systemPackages = [
    inputs.lg.packages.${system}.default # alias for `lg`
    # inputs.lg.packages.${system}.lg
    inputs.lg.packages.${system}.lga
    inputs.lg.packages.${system}.lge
];

# or home.nix
home.packages = [ inputs.lg.packages.${system}.default ];
```

### Otherwise

Download whichever shellscript you want, add a shebang, and install it however you usually would. Note that `lge` depends on `lga`, but `lga` is standalone (doesn't depend on `lg`).
