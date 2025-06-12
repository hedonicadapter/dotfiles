{
  inputs,
  outputs,
  pkgs,
}: let
  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;
  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.palette;
in {
  stylix.targets.spicetify.enable = false;
  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      keyboardShortcut
      groupSession
      powerBar
      beautifulLyrics
      skipStats
      songStats
      autoVolume
      adblock
      autoSkipVideo
    ];
    enabledCustomApps = with spicePkgs.apps; [marketplace];
    theme = spicePkgs.themes.text;
    colorScheme = "custom";

    customColorScheme = {
      text = colorsRGB.base0A;
      subtext = colorsRGB.base03;
      sidebar-text = colorsRGB.base05;
      main = colorsRGB.base00;
      sidebar = colorsRGB.base01;
      player = colorsRGB.base00;
      card = colorsRGB.base09;
      shadow = colorsRGB.base08;
      selected-row = colorsRGB.base0D;
      button = colorsRGB.base0C;
      button-active = colorsRGB.base0D;
      button-disabled = colorsRGB.base01;
      tab-active = colorsRGB.base08;
      notification = colorsRGB.base0B;
      notification-error = colorsRGB.base08;
      misc = colorsRGB.base00;
    };
  };
}
