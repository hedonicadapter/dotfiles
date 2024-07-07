{
  stylix.targets.foot.enable = false;
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        shell = "zsh";
        # font = "Iosevka Term:size=8";
        # font = "JetBrainsMono Nerd Font:size=13";
        font = "CartographCF Nerd Font:size=7.5";
        dpi-aware = "yes";
        pad = "24x0";
        line-height = 22.5;
      };
      colors = {
        foreground = "FFEFC2";
        background = "1c1c1c";
        selection-background = "292828";
        selection-foreground = "FFEFC2";
        regular0 = "af875f";
        regular1 = "875f5f";
        regular2 = "dfaf87";
        regular3 = "FFEFC2";
        regular4 = "87afaf";
        regular5 = "af5f5f";
        regular6 = "af8787";
        regular7 = "875f5f";
        bright0 = "87afaf";
        bright1 = "87875f";
        bright2 = "af5f00";
        bright3 = "dfaf87";
        bright4 = "dfdfaf";
        bright5 = "ffdf87";
        bright6 = "af875f";
        bright7 = "FFEFC2";
      };
      cursor = { blink = "yes"; };
    };
  };
}
