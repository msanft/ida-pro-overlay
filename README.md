# Nix Flake for IDA Pro

You can use the overlay provided by this flake along with your own IDA installer runfile to build your IDA Pro with Nix and use it on NixOS.

## How to Use

First, whether flakes are used or not, the IDA Pro installer must be made available for Nix.

This can be done by checking it into a private Git repository, supplying the build the path to the package, fetching the installer via the network, etc.

For example, the installer can be added to the store like so:

```sh
nix store add-file ida-pro_90_x64linux.run
```

This will then give you the store path, which is later used to instantiate the package.

### With Flakes

In your flake's inputs, import the overlay

```nix
ida-pro-overlay = {
    url = "path:/home/msanft/dev/ida-pro-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
};
```

Then, apply it to your `nixpkgs` instance with [`nixpkgs.overlays`](https://search.nixos.org/options?show=nixpkgs.overlays)

```nix
nixpkgs.overlays = [
    ida-pro-overlay.overlays.default
];
```

Then, you can instantiate the package, supplying it with your locally available installer

```nix
environment.systemPackages = [
    (callPackage ida-pro {
        # Alternatively, fetch the installer through `fetchurl`, use a local path, etc.
        runfile = /nix/store/z83flk6c9fm9li3gs13vbamq2szg9rwf-ida-pro_90_x64linux.run;
    })
];
```

IDA Pro should then be available in your system environment.
