{ lib, stdenv, fetchFromGitHub, unzip }:

stdenv.mkDerivation rec {
  pname = "Monolisa";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "lauer3912";
    repo = "Monolisa";
    rev = "master";
    sha256 = "sha256";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    cp *.ttf $out/share/fonts
  '';
}
