# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = 
  cartograph-cf = pkgs.callPackage ./cartograph-cf { };
}
