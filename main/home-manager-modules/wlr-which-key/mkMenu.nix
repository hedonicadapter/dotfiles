{
  pkgs,
  lib,
  outputs,
}: {
  menu,
  name,
}: let
  yamlFormat = pkgs.formats.yaml {};
  p = outputs.palette;

  # Same language as the AGS bar and menus: base00 panel, base05 text,
  # hairline base03 border, 1px corners, the stylix DOS font a bit larger
  # than the bar's 20px. wlr-which-key's defaults are gruvbox, monospace 10,
  # 4px green border and 20px corners.
  style = {
    font = "Mx437 DOS/V re. JPN30 14";
    background = p.base00;
    color = p.base05;
    border = p.base03;
    border_width = 1;
    corner_r = 1;
    padding = 10;
    column_padding = 24;
    separator = "  ";
    anchor = "center";
  };

  configFile = yamlFormat.generate "wlr-which-key-${name}.yaml" (style // {inherit menu;});
in
  pkgs.writeShellScriptBin "wlr-which-key-${name}" ''
    exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
  ''
