# OmniWM hotkeys can only run window-manager commands, so everything niri did with
# spawn / spawn-sh lives here instead. Modes stand in for the wlr-which-key menus
# (Mod+R/B/D/Q/U/S), same layout as the aerospace modes this replaces.
{pkgs, ...}: let
  # launchd agents get a bare PATH, so mode resets need the absolute binary.
  skhd = "${pkgs.skhd}/bin/skhd";
in {
  services.skhd = {
    enable = true;
    config = ''
      :: default
      :: run @
      :: browser @
      :: directories @
      :: query @
      :: utility @
      :: system @
      :: audio @
      :: display @
      :: powermenu @

      # niri Mod+T
      cmd - t : open -na kitty

      # niri Mod+Shift+P — power-off-monitors
      cmd + shift - p : pmset displaysleepnow

      cmd - r ; run
      cmd - b ; browser
      cmd - d ; directories
      cmd - q ; query
      cmd - u ; utility
      cmd - s ; system

      run < t : open -na kitty; ${skhd} -k 'escape'
      run < escape ; default

      browser < d : open -na Zen; ${skhd} -k 'escape'
      browser < z : open -na Zen; ${skhd} -k 'escape'
      browser < s : open -na Safari; ${skhd} -k 'escape'
      browser < c : open -na "Google Chrome"; ${skhd} -k 'escape'
      browser < escape ; default

      directories < d : open ~/Downloads; ${skhd} -k 'escape'
      directories < p : open ~/Documents/projects; ${skhd} -k 'escape'
      directories < t : open ~/.Trash; ${skhd} -k 'escape'
      directories < escape ; default

      # Spotlight
      query < a : osascript -e 'tell application "System Events" to key code 49 using {command down}'; ${skhd} -k 'escape'
      query < escape ; default

      # Interactive shot to clipboard, or full screen to niri's screenshot-path
      utility < p : screencapture -i -c; ${skhd} -k 'escape'
      utility < f : mkdir -p ~/Pictures/Screenshots && screencapture "$HOME/Pictures/Screenshots/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"; ${skhd} -k 'escape'
      utility < escape ; default

      system < a ; audio
      system < d ; display
      system < p ; powermenu
      system < escape ; default

      audio < j : osascript -e 'set volume output volume (output volume of (get volume settings) - 10)'
      audio < k : osascript -e 'set volume output volume (output volume of (get volume settings) + 10)'
      audio < m : osascript -e 'set volume output muted not (output muted of (get volume settings))'
      audio < escape ; default

      display < escape ; default

      powermenu < l : open -a ScreenSaverEngine; ${skhd} -k 'escape'
      powermenu < s : pmset sleepnow; ${skhd} -k 'escape'
      powermenu < escape ; default
    '';
  };
}
