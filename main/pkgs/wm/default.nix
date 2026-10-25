# `wm`: output queries and mode changes for scripts, on niri or Hyprland
{
  lib,
  writeShellApplication,
  jq,
  niri,
  hyprland,
}:
writeShellApplication {
  name = "wm";
  runtimeInputs = [jq niri hyprland];
  text = builtins.readFile ./wm.sh;
  meta.platforms = lib.platforms.linux;
}
