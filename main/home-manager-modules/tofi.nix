{
  config,
  lib,
  outputs,
  pkgs,
  ...
}: {
  stylix.targets.tofi.enable = false;
  programs.tofi = {
    enable = true;
    settings = {
      require-match = false;

      # Default anchor (center) anchors all four edges; niri then stretches the
      # surface to the whole output and tofi squeezes a full-screen buffer into
      # its small viewport at the top-left, redrawing it on every keystroke.
      # A corner anchor keeps the requested size; margins centre it.
      anchor = "top-left";
      width = "26%";
      height = "20%";
      margin-left = "37%";
      margin-top = "40%";
      border-width = 0;
      outline-width = 1;
      outline-color = outputs.palette.base04;
      padding-left = "0%";
      padding-top = "0%";
      num-results = 5;
      font = "${pkgs.ultimate-oldschool-pc-font-pack.outPath}/share/fonts/truetype/Mx437_DOS-V_re_JPN30.ttf";
      font-features = "liga 0";
      hint-font = false;

      text-cursor-corner-radius = 1;
      text-cursor-style = "block";
      text-cursor = true;

      font-size = 18;
      background-color = outputs.palette.base00;

      prompt-color = outputs.palette.base04;
      input-color = outputs.palette.base07;
      input-background = outputs.palette.base00;

      selection-color = outputs.palette.base00;
      selection-match-color = outputs.palette.base07;

      selection-background = outputs.palette.base0D;
      selection-background-corner-radius = 1;
      selection-background-padding = 1;

      history-file = "${config.home.homeDirectory}/.config/tofi/history";
    };
  };
}
