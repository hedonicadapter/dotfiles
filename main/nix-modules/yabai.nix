{
  services.yabai = {
    enable = true;

    config = {
      layout = "bsp";
      auto_balance = "on";

      mouse_follows_focus = "on";
      mouse_warping = "on";

      window_gap = 14;
      top_padding = 14;
      bottom_padding = 14;
      left_padding = 12;
      right_padding = 12;

      split_ratio = 0.5;

      focus_follows_mouse = "off";
      window_shadow = "on";
    };

    extraConfig = ''
      # startup
      yabai -m space --layout bsp

      # approximate aerospace normalization
      yabai -m config window_placement second_child

      # focus mouse warp
      yabai -m signal --add event=window_focused action="yabai -m window --warp mouse"
      yabai -m signal --add event=display_changed action="yabai -m window --warp mouse"
    '';
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''

      :: main

      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      alt + shift - h : yabai -m window --warp west
      alt + shift - j : yabai -m window --warp south
      alt + shift - k : yabai -m window --warp north
      alt + shift - l : yabai -m window --warp east

      alt + ctrl - h : yabai -m window --resize left:-30:0
      alt + ctrl - j : yabai -m window --resize bottom:0:30
      alt + ctrl - k : yabai -m window --resize top:0:-30
      alt + ctrl - l : yabai -m window --resize right:30:0

      alt - m : yabai -m window --toggle zoom-fullscreen
      alt + shift - f : yabai -m window --toggle float

      alt - w : yabai -m window --close

      # workspaces
      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5

      alt + shift - 1 : yabai -m window --space 1; yabai -m space --focus 1
      alt + shift - 2 : yabai -m window --space 2; yabai -m space --focus 2
      alt + shift - 3 : yabai -m window --space 3; yabai -m space --focus 3
      alt + shift - 4 : yabai -m window --space 4; yabai -m space --focus 4
      alt + shift - 5 : yabai -m window --space 5; yabai -m space --focus 5

      # modes
      alt - u ; : skhd -k "mode utility"
      alt - b ; : skhd -k "mode browser"
      alt - r ; : skhd -k "mode run"
      alt - s ; : skhd -k "mode system"

      :: run

      t : open -na kitty
      esc : skhd -k "mode main"

      :: browser

      d : open -na zen
      z : open -na Zen
      s : open -na Safari
      esc : skhd -k "mode main"

      :: utility

      p : screencapture -i -c
      esc : skhd -k "mode main"

      :: system

      a : skhd -k "mode audio"
      esc : skhd -k "mode main"

      :: audio

      j : osascript -e "set volume output volume ((output volume of (get volume settings)) - 5)"
      k : osascript -e "set volume output volume ((output volume of (get volume settings)) + 5)"
      esc : skhd -k "mode system"

    '';
  };
}
