{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  nix.enable = false;
  system.stateVersion = 6;

  users.users.samherman1 = {
    name = "samherman1";
    home = "/Users/samherman1";
  };

  imports = with inputs; [
    (import ../nix-modules/nix.nix {inherit inputs lib config;})
    (import ../nix-modules/nixpkgs.nix {inherit outputs;})
    # ./maintenance.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users.samherman1 = import ./home.nix;
    backupFileExtension = "backup";
    sharedModules = with inputs; [
      mac-app-util.homeManagerModules.default
      neovim-flake.homeModules.default
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  services = {
    jankyborders = {
      enable = true;
      hidpi = true;
      width = 8.0;
      order = "above";
      active_color = outputs.hexColorTo0xAARRGGBB outputs.palette.base07 1.0;
      inactive_color = outputs.hexColorTo0xAARRGGBB outputs.palette.base05 1.0;
    };
  };

  system = {
    primaryUser = "samherman1";
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      swapLeftCtrlAndFn = true;
    };
    defaults = {
      universalaccess.mouseDriverCursorSize = 4.0;
      finder = {
        ShowPathbar = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        ShowStatusBar = true;
      };
      ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0; # mouse accel
      NSGlobalDomain.AppleInterfaceStyle = null; # This option requires logging out and logging back in to apply. Type: null or value “Dark”
      dock = {
        autohide = true;
        wvous-tl-corner = 1;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tr-corner = 1;
      };

      NSGlobalDomain = {
        KeyRepeat = 2; # steps in GUI: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 12; # steps in GUI: 120, 94, 68, 35, 25, 15
        AppleShowAllFiles = true; # finder hidden files
        NSWindowShouldDragOnGesture = true; # ctrl + cmd + drag = drag windows
      };

      CustomSystemPreferences = {
        "/var/root/Library/Preferences/com.apple.CoreBrightness.plist" = let
          userId = builtins.readFile (pkgs.runCommand "user-id" {} "/usr/bin/dscl . -read /Users/samherman1 GeneratedUID | /usr/bin/sed 's/GeneratedUID: //' | /usr/bin/tr -d \\\\n > $out");
        in {
          "CBUser-${userId}" = {
            CBBlueLightReductionCCTTargetRaw = "3433.05";
            CBBlueReductionStatus = {
              AutoBlueReductionEnabled = 1;
              BlueLightReductionAlgoOverride = 0;
              BlueLightReductionDisableScheduleAlertCounter = 3;
              BlueLightReductionSchedule = {
                DayStartHour = 7;
                DayStartMinute = 0;
                NightStartHour = 22;
                NightStartMinute = 0;
              };
              BlueReductionAvailable = 1;
              BlueReductionEnabled = 1;
              BlueReductionMode = 1;
              BlueReductionSunScheduleAllowed = 1;
              Version = 1;
            };
            CBColorAdaptationEnabled = 1;
          };
        };
      };
    };
  };

  stylix = {
    enable = true;
    image = ../wallpapers/Frame21.png;
    polarity = "light";
    base16Scheme = outputs.palette;

    fonts = {
      serif = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Propo";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Propo";
      };
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Propo";
      };

      sizes.applications = 14;
      sizes.desktop = 14;
      sizes.popups = 14;
      sizes.terminal = 14;
    };
  };
}
