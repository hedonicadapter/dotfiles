{ config, pkgs, inputs, lib, ... }:
let
  spicetify-nix = inputs.spicetify-nix;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;

  inputImage =
    /home/hedonicadapter/Pictures/wallpapers-original/a_group_of_white_flowers_on_a_bush.jpg;
  brightness = 0;
  contrast = 40;
  fillColor = "black";
  saturation = 180; # Increase the saturation by 20%
in {
  services.blueman.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Authentication agent
  security.polkit.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  boot = {
    # plymouth = {
    #   enable = true;
    #   theme = "abstract_ring";
    #   themePackages = [
    #     (pkgs.adi1090x-plymouth-themes.override {
    #       selected_themes = [ "abstract_ring" ];
    #     })
    #   ];
    # };

    # silent boot options below
    loader.grub.timeoutStyle = false;
    # consoleLogLevel = 0;
    # initrd.verbose = false;
    # kernelParams = [
    # "quiet"
    # "splash"
    # "boot.shell_on_fail"
    # "i915.fastboot=1"
    # "loglevel=3"
    # "rd.systemd.show_status=false"
    # "rd.udev.log_level=3"
    # "udev.log_priority=3"
    # ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = true;
        configurationLimit = 100;
      };
    };
  };

  hardware.nvidia = {
    modesetting.enable = true; # Modesetting is required.

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    spicetify-nix.nixosModules.default
  ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod.enabled = "ibus"; # for emoji input
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "";
  };

  console.keyMap = "sv-latin1";

  services.printing.enable = true; # Enable CUPS to print documents.

  sound.enable = true; # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hedonicadapter = {
    isNormalUser = true;
    description = "hedonicadapter";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.docker.daemon.settings = {
    data-root = "~/Documents/coding/docker";
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "hedonicadapter" = import ./home.nix; };
  };

  # services.displayManager.autoLogin.enable = false;
  # services.displayManager.autoLogin.user = "hedonicadapter";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  environment.pathsToLink = [ "/share/bash-completion" ];

  nixpkgs.config = {
    permittedInsecurePackages = [
      "electron-25.9.0" # ONLY for obsidian at the moment
    ];
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "spotify"
        "microsoft-edge-dev"
        "vscode"
        "obsidian"
        "nvidia-settings"
        "steam"
        "steam-original"
        "steam-run"
      ];
  };

  environment.systemPackages = with pkgs; [
    # orchis-theme
    bibata-cursors-translucent
    fluent-icon-theme

    wine
    gcc
    python311Packages.cmake
    nodejs_21
    microsoft-edge-dev
    xorg.xmodmap
    git
    nix-output-monitor

    wev # event viewer
    atac
    zoxide
    ripgrep
    fd
    wl-clipboard
    swappy
    easyeffects
    brightnessctl
    pulseaudio
    playerctl
    spotify
    armcord

    swww
    wlsunset
    cliphist
    wl-clip-persist
    teams-for-linux
    vscode
    obsidian

    font-manager

    fsearch
  ];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "Gruvbox";
    injectCss = true;

    enabledCustomApps = with spicePkgs.apps; [ reddit marketplace ];
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      keyboardShortcut
      powerBar
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      skipStats
      autoVolume
      adblock
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    TERM = "foot";
  };

  xdg.portal.enable = true;

  stylix = {
    image = pkgs.runCommand "dimmed-background.png" { } ''
      ${pkgs.imagemagick}/bin/convert "${inputImage}" -brightness-contrast ${
        toString brightness
      },${toString contrast} -modulate 100,${
        toString saturation
      } -fill ${fillColor} $out
    '';
    polarity = "dark";
    base16Scheme = {
      base00 = "#292522";
      base01 = "#34302C";
      base02 = "#403A36";
      base03 = "#867462";
      base04 = "#C1A78E";
      base05 = "#ECE1D7";
      base06 = "#D47766";
      base07 = "#EBC06D";
      base08 = "#85B695";
      base09 = "#89B3B6";
      base0A = "#A3A9CE";
      base0B = "#CF9BC2";
      base0C = "#BD8183";
      base0D = "#E49B5D";
      base0E = "#78997A";
      base0F = "#7B9695";
    };
    # base16Scheme = {
    #   base00 = "#FBF1F2";
    #   base01 = "#8B8198";
    #   base02 = "#BFB9C6";
    #   base03 = "#585062";
    #   base04 = "#DCB16C";
    #   base05 = "#8B8198";
    #   base06 = "#7297B9";
    #   base07 = "#FBF1F2";
    #   base08 = "#D57E85";
    #   base09 = "#DCB16C";
    #   base0A = "#A3B367";
    #   base0B = "#69A9A7";
    #   base0C = "#69A9A7";
    #   base0D = "#7297B9";
    #   base0E = "#BB99B4";
    #   base0F = "#D57E85";
    # };
    targets = {
      chromium.enable = true;
      gnome.enable = true;
      gtk.enable = true;
    };

    fonts = {
      # pkgs.public-sans

      serif = {
        package = pkgs.merriweather;
        name = "Merriweather";
      };

      sansSerif = {
        package = pkgs.public-sans;
        name = "Work Sans";
      };

      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        # package = pkgs.nerdfonts.override { fonts = [ "ProggyClean" ]; };
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes.applications = 9;
      sizes.desktop = 9;
      sizes.popups = 9;
      sizes.terminal = 9;

    };
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # List services that you want to enable:
  services.logind = { lidSwitch = "ignore"; };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
