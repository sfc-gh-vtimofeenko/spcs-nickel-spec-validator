{
  description = "Description for the project";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs.follows = "nixpkgs-unstable";

    # Development deps
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          # self',
          # inputs',
          pkgs,
          # system,
          ...
        }:
        {
          packages = rec {
            default = spcs-spec-validator;
            spcs-spec-validator = import ./packages/spcs-nickel-spec-validator/package.nix {
              inherit (pkgs)
                writeShellApplication
                nickel
                symlinkJoin
                stdenv
                ;
            };
          };

          # Development stuff
          treefmt = {
            programs = {
              deadnix = {
                enable = true;
                no-lambda-arg = true;
                no-lambda-pattern-names = true;
                no-underscore = true;
              };
              statix.enable = true;
              nickel = {
                enable = true;
                package = pkgs.writeShellApplication {
                  name = "nickel-treefmt-wrapper";
                  runtimeInputs = [
                    pkgs.nickel
                    pkgs.coreutils
                  ];
                  text = ''
                    set -x
                    shift
                    for file in "$@"; do
                      ORIG_MD5=$(md5sum "$file" | cut -d ' ' -f 1)
                      NEW_MD5=$(nickel format < "$file" | md5sum | cut -d ' ' -f 1)
                      if [ "$ORIG_MD5" != "$NEW_MD5" ]; then
                        nickel format "$file"
                      fi
                    done
                  '';
                };
              };
              nixfmt = {
                enable = true;
                package = pkgs.writeShellApplication {
                  name = "nixfmt-rfc-style-treefmt-wrapper";
                  runtimeInputs = [
                    pkgs.nixfmt-rfc-style
                    pkgs.coreutils
                  ];
                  text = ''
                    set -x
                    for file in "$@"; do
                      ORIG_MD5=$(md5sum "$file" | cut -d ' ' -f 1)
                      NEW_MD5=$(nixfmt < "$file" | md5sum | cut -d ' ' -f 1)
                      if [ "$ORIG_MD5" != "$NEW_MD5" ]; then
                        nixfmt "$file"
                      fi
                    done
                  '';
                };
              };
            };
            projectRootFile = "flake.nix";
          };

          pre-commit.settings = {
            hooks = {
              treefmt.enable = true;
              deadnix.enable = true;
              statix.enable = true;
              shellcheck.enable = true;
              markdownlint.enable = true;
            };
            settings = {
              deadnix.edit = true;
              statix = {
                ignore = [ ".direnv/" ];
                format = "stderr";
              };
              markdownlint.config.MD041 = false; # Disable "first line should be a heading check"
              treefmt.package = config.treefmt.build.wrapper;
            };
          };

          devShells.pre-commit = config.pre-commit.devShell;
          devshells.default = {
            env = [ ];
            commands = [ ];
            packages = builtins.attrValues { inherit (pkgs) nickel nls; };
          };
        };
      flake = { };
    };
}
