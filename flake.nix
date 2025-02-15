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

      perSystem = { pkgs, stdenv, lib, ... }:
        let
          zig = pkgs.zig_0_13;
          hobos = pkgs.callPackage ./utils/nix/hobos { };
          runner = pkgs.callPackage ./utils/nix/runner {
            inherit hobos;
          };
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixpkgs-fmt.enable = true;
            programs.zig.enable = true;
            programs.actionlint.enable = true;
          };

          checks = {
            inherit hobos;
          };

          packages = {
            inherit hobos runner;
            default = hobos;
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              # Compiler
              zig

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
