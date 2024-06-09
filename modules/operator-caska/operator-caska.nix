{ lib, stdenv, fetchFromGitHub, unzip }:

stdenv.mkDerivation rec {
  pname = "Operator-Caska";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Anant-mishra1729";
    repo = "Operator-caska-Font";
    rev = "main";
    sha256 = "sha256-NhXcSkbLO2xvwUD2s6xvG/0Sjhd4YazQPjpVcY2oSDc=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp *.ttf $out/share/fonts/truetype
  '';
}
