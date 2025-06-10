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
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nvim = let
    inherit (inputs.neovim-flake) utils;
    basePackage = inputs.neovim-flake.packageDefinitions.nvim or ({...}: {});
  in {
    enable = true;
    packageDefinitions = {
      merge.nvim = utils.mergeCatDefs basePackage ({pkgs, ...}: {
        extra.palette = outputs.palette;
        extra.palette_opaque = outputs.paletteOpaque;
        extra.contrast =
          if outputs.isDarkColor outputs.palette.base00
          then 0.6
          else -0.8;

        extra.modeColors = {
          n = outputs.paletteOpaque.base03;
          i = outputs.paletteOpaque.base0F;

          c = outputs.paletteOpaque.base0E;
          C = outputs.paletteOpaque.base0E;

          v = outputs.paletteOpaque.base0C;
          V = outputs.paletteOpaque.base0C;

          r = outputs.paletteOpaque.base0E;
          R = outputs.paletteOpaque.base0E;

          s = outputs.paletteOpaque.base0E;
          S = outputs.paletteOpaque.base0E;

          y = outputs.paletteOpaque.base0D;
        };
      });
    };
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
      };

      NSGlobalDomain = {
        KeyRepeat = 1;
        InitialKeyRepeat = 1;
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
              BlueReductionEnabled = 0;
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
    # pkgs.runCommand "dimmed-background.png" {} ''
    #   ${pkgs.imagemagick}/bin/magick "${inputImage}" -brightness-contrast ${
    #     toString brightness
    #   },${toString contrast} -modulate 100,${
    #     toString saturation
    #   } -fill "${fillColor}" $out
    # '';
    polarity = "light";
    base16Scheme = outputs.palette;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.victor-mono;
        name = "Victor Mono";
      };

      sizes.applications = 14;
      sizes.desktop = 14;
      sizes.popups = 14;
      sizes.terminal = 14;
    };
  };
}
