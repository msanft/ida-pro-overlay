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
        ida-pro = self.packages.x86_64-linux.ida-pro;
      };
    };
}
