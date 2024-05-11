with import <nixpkgs> { };
stdenv.mkDerivation {
  name = "python-environment";
  buildInputs = [ python3Packages.virtualenv opencv4 gcc stdenv.cc.cc.lib ];
}
