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
                lg = self.packages.${final.system}.default;
            })];

            environment.systemPackages = [ pkgs.lg ];
        };

        packages = nixpkgs.lib.genAttrs systems (system: let
            pkgs = import nixpkgs { inherit system; };
        in {
            default = pkgs.resholve.writeScriptBin "lg" {
                interpreter = "${pkgs.bash}/bin/bash";
                execer = [
                    "cannot:${pkgs.procps}/bin/watch"
                    "cannot:${pkgs.less}/bin/less"
                ];

                inputs = [
                    pkgs.coreutils
                    pkgs.procps
                    pkgs.less
                ];
            } (builtins.readFile ./lg.sh);
        });
    };
}
