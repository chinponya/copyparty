{
  # https://github.com/NixOS/nixpkgs/pull/214454
  # inputs = { nixpkgs.url = "github:winterqt/nixpkgs/prefetch-npm-deps-fixup-hashes"; };
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        copypartyPkgs = pkgs: import ./contrib/nix/pkgs { inherit pkgs; };
      in {
        overlays.default = final: prev: {
          inherit (copypartyPkgs final) copyparty;
        };

        packages = (copypartyPkgs pkgs) // {
          default = self.packages.${system}.copyparty;
        };

        devShells.default = import ./contrib/nix/devshells { inherit pkgs; };
      });
}
