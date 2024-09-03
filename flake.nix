{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        stdenv = pkgs.stdenv;
        zig = pkgs.zig_0_13;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        hobos = stdenv.mkDerivation {
          pname = "hobos";
          version = "dev";

          src = ./.;

          nativeBuildInputs = [
            zig.hook
          ];

          zigBuildFlags = [
            "-Doptimize=Debug"
            "-Dtarget=riscv32-freestanding"
          ];
        };
        runner = pkgs.writeShellApplication {
          name = "runner";
          runtimeInputs = [
            pkgs.qemu_full
          ];

          text = ''
            qemu-system-riscv32 -machine virt -bios default -serial mon:stdio -kernel ${hobos}/bin/hobos.elf
          '';
        };
      in
      {
        # Use `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # Use `nix flake check`
        checks = {
          inherit hobos;
          formatting = treefmtEval.config.build.check self;
        };

        apps.default = flake-utils.lib.mkApp {
          drv = runner;
        };

        # nix build .
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
      });
}
