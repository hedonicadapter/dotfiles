{ lib, stdenv, fetchFromGitHub, unzip }:

stdenv.mkDerivation rec {
  pname = "cartograph-cf";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "xiyaowong";
    repo = "Cartograph-CF";
    rev = "main";
    sha256 = "sha256-NhXcSkbLO2xvwUD2s6xvG/0Sjhd4YazQPjpVcY2oSDc=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cd "Nerd Font"
    cp *.ttf $out/share/fonts/truetype
  '';
}
