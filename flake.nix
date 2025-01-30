{
  description = "Perimeter81 on Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      flake-parts,
      nixpkgs,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        inputs,
        lib,
        withSystem,
        ...
      }:
      {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.treefmt-nix.flakeModule
        ];
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            config,
            pkgs,
            system,
            ...
          }:
          {
            treefmt = {
              programs.nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              programs.mdformat.enable = true;
            };

            overlayAttrs = {
              inherit (config.packages) perimeter81 perimeter81-unwrapped;
            };

            packages = {
              perimeter81-unwrapped = pkgs.callPackage ./package.nix { };
              perimeter81 = pkgs.callPackage ./fhsenv.nix { inherit (config.packages) perimeter81-unwrapped; };
            };

          };

        flake = {
          nixosModules = {
            perimeter81 = {
              imports = [
                ./module.nix
              ];
              nixpkgs.overlays = [
                self.overlays.default
              ];
            };
            default = self.nixosModules.perimeter81;
          };
        };
      }
    );

}
