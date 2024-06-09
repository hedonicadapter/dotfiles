{ lib, stdenv, fetchFromGitHub, unzip }:

stdenv.mkDerivation rec {
  pname = "Monolisa";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "lauer3912";
    repo = "Monolisa";
    rev = "master";
    sha256 = "sha256-NhXcSkbLO2xvwUD2s6xvG/0Sjhd4YazQPjpVcY2oSDc=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp *.ttf $out/share/fonts/truetype
  '';
}
