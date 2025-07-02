{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          pkgs,
          stdenv,
          lib,
          ...
        }:
        let
          hobos = pkgs.stdenv.mkDerivation {
            pname = "hobos";
            version = "dev";
            src = lib.cleanSource ./.;

            nativeBuildInputs = [
              pkgs.zig_0_14.hook
            ];
          };
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.zig.enable = true;
            programs.actionlint.enable = true;
          };

          packages = {
            inherit hobos;
            default = hobos;
          };

          checks = {
            inherit hobos;
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              # Compiler
              pkgs.zig_0_14

              # LSP
              pkgs.zls
              pkgs.nil

              # QEMU
              pkgs.qemu_full

              # LLVM Tools
              pkgs.libllvm
            ];

            shellHook = ''
              export PS1="\n[nix-shell:\w]$ "
            '';
          };
        };
    };
}
