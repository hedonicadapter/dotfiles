# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example =
  # cartograph-cf = pkgs.callPackage ./cartograph-cf { };
  stay-awake = pkgs.callPackage ./stay-awake {};
  speed-read = pkgs.callPackage ./speed-read {};

  # Darwin-only, enforced by meta.platforms — do NOT gate this with
  # optionalAttrs pkgs.stdenv…, the additions overlay would then need the
  # fixpoint to know its own attribute names (infinite recursion).
  omniwm = pkgs.callPackage ./omniwm {};
}
