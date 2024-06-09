{ lib, stdenv, fetchurl, unzip }:
let
  src = builtins.fetchGit {
    url = "https://github.com/xiyaowong/Cartograph-CF";
    rev = "619de85c103dbd5c150e1d5df039357f8ac2ed52";
  };
in stdenv.mkDerivation {
  name = "cartograph-cf";
  # nativeBuildInputs = [ unzip ];
  unpackPhase = "true"; # disable the unpackPhase

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp -r ${src}/Nerd\ Font/* $out/share/fonts/truetype
  '';
}
