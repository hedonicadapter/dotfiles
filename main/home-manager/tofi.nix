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
      width = "100%";
      height = "100%";
      border-width = 0;
      outline-width = 0;
      padding-left = "45%";
      padding-top = "35%";
      result-spacing = 10;
      num-results = 5;
      font = "--font ${pkgs.public-sans}/share/fonts/opentype/PublicSans-Regular.otf";
      font-features = "liga 0";
      hint-font = false;
      text-cursor-corner-radius = 1;
      font-size = 22;
      background-color = "#000A";

      prompt-color = outputs.colors.grey;
      input-color = outputs.colors.white;
      input-background = "#0000";

      selection-color = outputs.colors.grey;
      selection-background = outputs.colors.yellow;
      selection-background-corner-radius = 1;
      selection-background-padding = 4;

      selection-match-color = outputs.colors.vanilla_pear;

      history-file = "${config.home.homeDirectory}/.config/tofi/history";
    };
  };
}
