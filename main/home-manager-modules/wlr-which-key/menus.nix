{
  pkgs,
  lib,
  ...
}: let
  mkMenu = import ./mkMenu.nix {inherit pkgs lib;};

  terminal = "kitty";
  music = "spotify";
  mail = "xdg-open https://mail.google.com";
  browser = "zen-beta";
  fileManager = "nautilus";
  appQuery = "tofi-run | xargs hyprctl dispatch exec --";
  homeManagerQuery = "home-manager-options.extranix.com";
  clipboardHistoryQuery = "cliphist list | tofi | cliphist decode | wl-copy";

  powerMenu = mkMenu {
    name = "power";
    menu = [
      {
        key = "q";
        desc = "SHUT DOWN";
        cmd = "sudo shutdown -h now";
      }
      {
        key = "r";
        desc = "REBOOT";
        cmd = "sudo shutdown -r now";
      }
    ];
  };

  audioMenu = mkMenu {
    name = "audio";
    menu = [
      {
        key = "p";
        desc = "PLAY/PAUSE";
        cmd = "playerctl play-pause";
      }
      {
        key = "l";
        desc = "NEXT";
        cmd = "playerctl next";
      }
      {
        key = "h";
        desc = "PREVIOUS";
        cmd = "playerctl previous";
      }
      {
        key = "k";
        desc = "VOL UP";
        cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+";
      }
      {
        key = "j";
        desc = "VOL DOWN";
        cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-";
      }
      {
        key = "m";
        desc = "MUTE/UNMUTE OUT";
        cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      }
      {
        key = "i";
        desc = "MUTE/UNMUTE IN";
        cmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      }
      {
        key = "s";
        desc = "AUDIO SETTINGS";
        cmd = "easyeffects";
      }
    ];
  };

  displayMenu = mkMenu {
    name = "display";
    menu = [
      {
        key = "k";
        desc = "BRIGHTNESS UP";
        cmd = "brightnessctl set +10%";
      }
      {
        key = "j";
        desc = "BRIGHTNESS DOWN";
        cmd = "brightnessctl set 10%-";
      }
    ];
  };

  runMenu = mkMenu {
    name = "run";
    menu = [
      {
        key = "t";
        desc = "TERMINAL";
        cmd = "${terminal}";
      }
      {
        key = "m";
        desc = "MUSIC";
        cmd = "${music}";
      }
      {
        key = "e";
        desc = "MAIL";
        cmd = "${mail}";
      }
      {
        key = "d";
        desc = "DISCORD";
        cmd = "vesktop";
      }
      {
        key = "s";
        desc = "M0XYY";
        cmd = "${terminal} 'streamlink twitch.tv/m0xyy 720p60 --player mpv --twitch-low-latency & TERM=xterm-kitty twt'";
      }
      {
        key = "y";
        desc = "YOUTUBE";
        cmd = "${terminal} pipe-viewer";
      }
    ];
  };

  browserMenu = mkMenu {
    name = "browser";
    menu = [
      {
        key = "b";
        desc = "DEFAULT";
        cmd = "${browser}";
      }
      {
        key = "f";
        desc = "FIREFOX";
        cmd = "firefox-beta";
      }
      {
        key = "z";
        desc = "ZEN BROWSER";
        cmd = "zen-beta";
      }
      {
        key = "e";
        desc = "EDGE";
        cmd = "microsoft-edge";
      }
    ];
  };

  directoriesMenu = mkMenu {
    name = "directories";
    menu = [
      {
        key = "t";
        desc = "TEMP";
        cmd = "${fileManager} ~/Documents/temp";
      }
      {
        key = "d";
        desc = "DOWNLOADS";
        cmd = "${fileManager} ~/Downloads";
      }
    ];
  };

  queryMenu = mkMenu {
    name = "query";
    menu = [
      {
        key = "a";
        desc = "APPS";
        cmd = "${appQuery}";
      }
      {
        key = "h";
        desc = "HOME MANAGER OPTIONS";
        cmd = "xdg-open 'https://${homeManagerQuery}'";
      }
      {
        key = "c";
        desc = "CLIPBOARD";
        cmd = "${clipboardHistoryQuery}";
      }
    ];
  };

  utilityMenu = mkMenu {
    name = "utility";
    menu = [
      {
        key = "p";
        desc = "PRINT-SCREEN";
        cmd = "grim -g \"$(slurp)\" - | swappy -f - | wl-copy";
      }
      {
        key = "c";
        desc = "COLOR PICKER";
        cmd = "hyprpicker -a";
      }
      {
        key = "r";
        desc = "SPEED READER";
        cmd = "${terminal} bash ~/.config/hypr/speed-read.sh";
      }
      {
        key = "e";
        desc = "EMOJI PICKER";
        cmd = "rofimoji --selector tofi";
      }
      {
        key = "y";
        desc = "AI YAP SESH";
        cmd = "astal toggleHAL";
      }
    ];
  };

  systemMenu = mkMenu {
    name = "system";
    menu = [
      {
        key = "r";
        desc = "RELOAD SHELL";
        cmd = "ags quit; ags run & hyprctl reload && sleep 3 && hyprctl seterror disable";
      }
      {
        key = "z";
        desc = "TOGGLE ZEN MODE";
        cmd = "astal zenable";
      }

      {
        key = "p";
        desc = "POWER MENU...";
        cmd = "${lib.getExe powerMenu}";
      }
      {
        key = "a";
        desc = "AUDIO MENU...";
        cmd = "${lib.getExe audioMenu}";
      }
      {
        key = "d";
        desc = "DISPLAY MENU...";
        cmd = "${lib.getExe displayMenu}";
      }
    ];
  };
in {
  inherit
    runMenu
    browserMenu
    directoriesMenu
    queryMenu
    utilityMenu
    systemMenu
    powerMenu
    audioMenu
    displayMenu
    ;
}
