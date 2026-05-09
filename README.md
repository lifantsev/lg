# lg

A simple set of scripts for reading and writing log files.

- [lg](#logging), [lga](#lga), [lge](#lge)

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

The start and finish commands create a much shorter line and thus create visual breaks in the log file. Any other log must have a log level (capital letter in arg 1) and a log string (arg 2). These types of logs include a timestamp in the logfile. There is a special log level `E`, which will cause logs to be written not only to the logfile but also to stdout:
``` sh
lg E "expected A but got B" # warning: this will write to stdout
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

### lga

A secondary script `lga` is provided. The a stands for asynchronous, it forks a background process that completes the logging, which makes scripts faster. It has the same interface as `lg` for [logging](#logging) but does not provide [viewing functionality](#viewing). Also, it never prints to stdout, even if given the 'E' log level.

### lge

A third script `lge` is provided. The e stands for error. Running `lge "my error"` is similar to `lg E "my error"` except it uses [lga](#lga) to write to the logfile, making it slightly faster. It prints an appropriate error message to stdout, unlike [lga](#lga).

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
