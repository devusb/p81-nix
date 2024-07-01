{
  description = "Perimeter81 on Nix";
  inputs = {nixpkgs = {url = "nixpkgs/nixos-unstable";};};
  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    perimeter81-unwrapped = pkgs.callPackage ./perimeter81.nix {};
    perimeter81 = pkgs.callPackage ./fhsenv.nix {inherit perimeter81-unwrapped;};
  in rec {
    packages.${system} = {
      inherit perimeter81;
    };
    defaultPackage.${system} = packages.${system}.perimeter81;

    overlays = {
      default = _: _: {
        perimeter81 = defaultPackage.${system};
      };
    };

    nixosModules = {
      perimeter81 = {
        imports = [
          ./module.nix
        ];
        nixpkgs.overlays = [
          self.overlays.default
        ];
      };
    };
  };
}
