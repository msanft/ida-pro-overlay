# Nix Flake for IDA Pro

You can use the overlay provided by this flake along with your own IDA installer runfile to build an IDA Pro package with Nix and use it on NixOS.

## How to Use

First, the IDA Pro installer must be made available for Nix.

Add the installer to the store like so:

```sh
nix store add-file ida-pro_92_x64linux.run
```

It will then be picked up automatically as a dependency.

### With Flakes

In your flake's inputs, import the overlay

```nix
ida-pro-overlay = {
    url = "github:msanft/ida-pro-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
};
```

Then, apply it to your `nixpkgs` instance with [`nixpkgs.overlays`](https://search.nixos.org/options?show=nixpkgs.overlays)

```nix
nixpkgs.overlays = [
    ida-pro-overlay.overlays.default
];
```

Then, you can instantiate the package.

```nix
environment.systemPackages = [
    ida-pro
];
```

IDA Pro should then be available in your system environment.
