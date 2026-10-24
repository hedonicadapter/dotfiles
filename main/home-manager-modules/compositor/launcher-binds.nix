# Spawn binds for niri and Hyprland; layout binds stay per compositor.
# Mod is Super. locked: also fires on the lock screen.
[
  {
    key = "R";
    desc = "Run menu";
    cmd = "wlr-which-key-run";
  }
  {
    key = "B";
    desc = "Browser menu";
    cmd = "wlr-which-key-browser";
  }
  {
    key = "D";
    desc = "Directories menu";
    cmd = "wlr-which-key-directories";
  }
  {
    key = "Q";
    desc = "Query menu";
    cmd = "wlr-which-key-query";
  }
  {
    key = "U";
    desc = "Utility menu";
    cmd = "wlr-which-key-utility";
  }
  {
    key = "S";
    desc = "System menu";
    cmd = "wlr-which-key-system";
  }
  {
    key = "V";
    desc = "Hints";
    cmd = "hints";
  }
  {
    key = "T";
    desc = "Open a Terminal: kitty";
    cmd = "kitty";
  }

  {
    mods = [];
    key = "XF86AudioRaiseVolume";
    desc = "Volume up";
    cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
    locked = true;
  }
  {
    mods = [];
    key = "XF86AudioLowerVolume";
    desc = "Volume down";
    cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
    locked = true;
  }
  {
    mods = [];
    key = "XF86AudioMute";
    desc = "Mute output";
    cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    locked = true;
  }
  {
    mods = [];
    key = "XF86AudioMicMute";
    desc = "Mute input";
    cmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    locked = true;
  }

  {
    mods = [];
    key = "XF86AudioPlay";
    desc = "Play/pause";
    cmd = "playerctl play-pause";
    locked = true;
  }
  {
    mods = [];
    key = "XF86AudioPause";
    desc = "Play/pause";
    cmd = "playerctl play-pause";
    locked = true;
  }
  {
    mods = [];
    key = "XF86AudioStop";
    desc = "Stop";
    cmd = "playerctl stop";
    locked = true;
  }
  {
    mods = [];
    key = "XF86AudioPrev";
    desc = "Previous track";
    cmd = "playerctl previous";
    locked = true;
  }
  {
    mods = [];
    key = "XF86AudioNext";
    desc = "Next track";
    cmd = "playerctl next";
    locked = true;
  }

  {
    mods = [];
    key = "XF86MonBrightnessUp";
    desc = "Brightness up";
    cmd = "brightnessctl --class=backlight set +10%";
    locked = true;
  }
  {
    mods = [];
    key = "XF86MonBrightnessDown";
    desc = "Brightness down";
    cmd = "brightnessctl --class=backlight set 10%-";
    locked = true;
  }
]
