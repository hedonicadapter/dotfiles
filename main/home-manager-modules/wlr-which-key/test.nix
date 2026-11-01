# nix-build test.nix && cat $(grep -o '/nix/store/[^ ]*\.yaml' result/bin/wlr-which-key-test)
let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  outputs = {palette = builtins.fromJSON (builtins.readFile ../../palette.json);};
  mkMenu = import ./mkMenu.nix {inherit pkgs lib outputs;};
in
  mkMenu {
    menu = [
      {
        key = "t";
        desc = "TERMINAL";
        cmd = "kitty";
      }
    ];
    name = "test";
  }
