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
          ...
        }:
        let
          buildInputs = [ ];
          nativeBuildInputs = [
            pkgs.zig_0_16 # Ziglang compiler
            pkgs.zls_0_16 # Ziglang LSP
            pkgs.nil # Nix LSP
            pkgs.qemu # Qemu
          ];
        in
        {
          treefmt = {
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;

            # Zig
            programs.zig.enable = true;
            programs.zig.package = pkgs.zig_0_16;

            # GitHub Actions
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # Shell Script
            programs.shfmt.enable = true;
            programs.shellcheck.enable = true;
          };

          devShells.default = pkgs.mkShell {
            inherit buildInputs nativeBuildInputs;
          };
        };
    };
}
