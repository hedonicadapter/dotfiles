{
  pkgs,
  lib,
}: {
  menu,
  name,
}: let
  yamlFormat = pkgs.formats.yaml {};

  configFile = yamlFormat.generate "wlr-which-key-${name}.yaml" {
    inherit menu;
  };
in
  pkgs.writeShellScriptBin "wlr-which-key-${name}" ''
    exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
  ''
