{
  config,
  lib,
  outputs,
  ...
}: {
  # stylix.targets.tofi.enable = false;
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
      font = lib.mkForce "Public Sans";
      font-size = lib.mkForce 24;
      background-color = lib.mkForce "#000A";
      selection-match-color = lib.mkForce outputs.colors.blue;

      history-file = "${config.home.homeDirectory}/.config/tofi/history";
    };
  };
}
