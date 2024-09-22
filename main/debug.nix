# various debugging things
# let
#   pkgs = import <nixpkgs> {
#     overlays = [
#       (import (builtins.fetchTarball {
#         url = "https://github.com/m15a/flake-awesome-neovim-plugins/archive/main.tar.gz";
#       }))
#       .overlays
#       .default
#     ];
#   };
# in
#   builtins.attrNames pkgs.vimPlugins
# nix-instantiate --eval debug.nix | tr ' ' '\n' | sort | fzf
#
let
  flake = builtins.getFlake "github:m15a/flake-awesome-neovim-plugins";
  system = builtins.currentSystem;
in
  builtins.attrNames flake.packages.${system}
# nix eval --file debug.nix

