# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs:
{
  # example =
  # cartograph-cf = pkgs.callPackage ./cartograph-cf { };
  stay-awake = pkgs.callPackage ./stay-awake {};
  speed-read = pkgs.callPackage ./speed-read {};
}
// pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
  omniwm = pkgs.callPackage ./omniwm {};
}
