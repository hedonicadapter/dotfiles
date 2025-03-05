# {pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
# pkgs.mkShell {
#   packages = with pkgs; [
#     (python312.withPackages (python-pkgs:
#       with python-pkgs; [
#         conda
#         numpy
#       ]))
#     ffmpeg
#   ];
#
#   shellHook = ''
#     export LD_LIBRARY_PATH=${pkgs.libGL}/lib/:${pkgs.stdenv.cc.cc.lib}/lib/:${pkgs.glibc}/lib
#   '';
# }
{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.mkShell {
  packages = with pkgs; [
    (python312Full.withPackages (python-pkgs:
      with python-pkgs; [
        opencv4
      ]))
    conda
    ffmpeg
    glibc
  ];
}
