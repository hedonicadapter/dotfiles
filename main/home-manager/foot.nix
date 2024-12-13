{outputs, ...}: let
  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;

  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.colors;
in {
  stylix.targets.foot.enable = false;
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        shell = "zsh";
        # font = "Iosevka Term:size=8";
        # font = "JetBrainsMono Nerd Font:size=13";
        font = "vt323:size=7.5";
        dpi-aware = "yes";
        pad = "24x1";
        line-height = 16;
      };
      colors = {
        alpha = 0.86;
        foreground = colorsRGB.vanilla_pear;
        background = colorsRGB.black;
        selection-background = colorsRGB.grey;
        selection-foreground = colorsRGB.vanilla_pear;
        regular0 = colorsRGB.beige;
        regular1 = colorsRGB.burgundy;
        regular2 = colorsRGB.orange_dim;
        regular3 = colorsRGB.vanilla_pear;
        regular4 = colorsRGB.cyan;
        regular5 = colorsRGB.red;
        regular6 = colorsRGB.blush;
        regular7 = colorsRGB.burgundy;
        bright0 = colorsRGB.cyan;
        bright1 = colorsRGB.green;
        bright2 = colorsRGB.orange;
        bright3 = colorsRGB.orange_dim;
        bright4 = colorsRGB.beige;
        bright5 = colorsRGB.yellow;
        bright6 = colorsRGB.beige;
        bright7 = colorsRGB.vanilla_pear;
      };
      cursor = {blink = "yes";};
    };
  };
}
