{
  description = "Nix flake for IDA Pro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      ...
    }:
    {
      overlays.default = self: super: {
        # use super here to inherit allowUnfree status
        ida-pro = super.callPackage ./packages/ida-pro.nix {};
      };
    };
}
