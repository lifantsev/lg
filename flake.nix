{
    description = "lg: a bash script for logging and viewing logs";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    };

    outputs = { self, nixpkgs, ... }: let
        systems = [ "aarch64-linux" "x86_64-linux" ];
    in {
        nixosModules.default = { pkgs, ... }: {
            nixpkgs.overlays = [(final: prev: {
                lg = self.packages.${final.system}.lg;
                lga = self.packages.${final.system}.lga;
                lge = self.packages.${final.system}.lge;
            })];

            environment.systemPackages = [
                pkgs.lg
                pkgs.lga
                pkgs.lge
            ];
        };

        packages = nixpkgs.lib.genAttrs systems (system: let
            pkgs = import nixpkgs { inherit system; };

            build = name: { inputs, execer?[] }: pkgs.resholve.writeScriptBin name {
                interpreter = "${pkgs.bash}/bin/bash";
                inherit inputs execer;
            } (builtins.readFile (./. + "/${name}.sh"));

            lg = build "lg" {
                execer = [
                    "cannot:${pkgs.procps}/bin/watch"
                    "cannot:${pkgs.less}/bin/less"
                ];

                inputs = [
                    pkgs.coreutils
                    pkgs.gnugrep
                    pkgs.gawk
                    pkgs.gnused
                    pkgs.bc
                    pkgs.procps
                    pkgs.less
                ];
            };

            lga = build "lga" {
                execer = [ "cannot:${pkgs.util-linux}/bin/flock" ];

                inputs = [
                    pkgs.coreutils
                    pkgs.util-linux
                    pkgs.gnugrep
                    pkgs.gawk
                    pkgs.gnused
                    pkgs.bc
                ];
            };

            lge = build "lge" {
                execer = [ "cannot:${lga}/bin/lga" ];

                inputs = [
                    pkgs.coreutils
                    lga
                ];
            };
        in {
            inherit lg lga lge;
            default = lg;
        });
    };
}
