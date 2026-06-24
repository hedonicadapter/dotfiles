# test.nix
let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  mkMenu = builtins.scopedImport {inherit pkgs lib;} ./mkMenu.nix;
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
