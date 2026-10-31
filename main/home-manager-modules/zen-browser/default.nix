# Zen browser profile files and a playback diagnostic.
#
# Zen 1.21+ locks `widget.support-xdg-config` on, so a fresh install lives in
# ~/.config/zen; an existing ~/.zen keeps being used. The profile below predates
# the move, hence the legacy path.
{
  outputs,
  pkgs,
  config,
  ...
}: let
  profile = "${config.home.homeDirectory}/.zen/wx2n5f38.default";

  diag = pkgs.writeShellApplication {
    name = "zen-video-diag";
    runtimeInputs = with pkgs; [libva-utils pciutils coreutils gnugrep gnused procps];
    text = builtins.readFile ./zen-video-diag.sh;
  };
in {
  home.packages = [diag];

  home.file = {
    "${profile}/chrome/userChrome.css".text = import ./userChrome.css.nix {inherit outputs;};
    "${profile}/chrome/userContent.css".text = import ./userContent.css.nix {inherit outputs;};
    "${profile}/user.js".source = ./user.js;
  };
}
