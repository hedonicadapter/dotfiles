{ config, ... }: {
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
      result-spacing = 18;
      num-results = 5;
      font = "Public Sans";
      font-size = 24;
      background-color = "#000A";
      prompt-color = "#bdae93";
      selection-color = "#fbf1c7";
      selection-match-color = "#a9b665";

      history-file = "${config.home.homeDirectory}/.config/tofi/history";
    };
  };
}
