{
  description = "Nix flake for IDA Pro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      overlays.default = self: super: {
        # use super here to inherit allowUnfree status
        ida-pro = super.callPackage ./packages/ida-pro.nix {};
      };
      packages.${system}.default = pkgs.callPackage ./packages/ida-pro.nix {};
    };
}
