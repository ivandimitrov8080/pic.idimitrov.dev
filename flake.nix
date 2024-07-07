{
  description = "Rust Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fnx = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    ide = { url = "github:ivandimitrov8080/flake-ide"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { nixpkgs, fnx, ide, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            nvim = ide.nvim.${system}.standalone.default {
              plugins = {
                rust-tools.enable = true;
                lsp.servers = { rust-analyzer = { enable = true; installCargo = false; installRustc = false; }; };
              };
            };
          })
          fnx.overlays.default
        ];
      };
      buildInputs = with pkgs; [
        (fenix.complete.withComponents [ "cargo" "clippy" "rust-src" "rustc" "rustfmt" ])
        rust-analyzer-nightly
        nvim
      ];
      nativeBuildInputs = with pkgs; [
        (fenix.complete.withComponents [ "cargo" "rustc" ])
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit buildInputs nativeBuildInputs;
      };
      packages.${system} = {
        default = pkgs.rustPlatform.buildRustPackage {
          inherit nativeBuildInputs;
          name = "pic.idimitrov.dev";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
      };
    };
}
