{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python311Packages.python
    python311Packages.virtualenv
    wget  # to download the .whl file
    libGL
    glib
  ];

  shellHook = ''
    virtualenv venv
    source venv/bin/activate
    export LD_LIBRARY_PATH="${pkgs.libGL.out}/lib:${pkgs.glib.out}/lib:$LD_LIBRARY_PATH"
  '';
}