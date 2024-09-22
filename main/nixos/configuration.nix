{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  spicetify-nix = inputs.spicetify-nix;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;

  brightness = 0;
  contrast = 0;
  fillColor = outputs.colors.black;
  saturation = 100;

  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;

  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.colors;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.nur.nixosModules.nur
    spicetify-nix.nixosModules.default
    inputs.xremap-flake.nixosModules.default

    ./maintenance.nix
    ./hardware-configuration.nix

    (import ../modules/nixos/mousekeys/default.nix {inherit pkgs;})
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {hedonicadapter = import ../home-manager/home.nix;};
    backupFileExtension = "backup";
  };

  nixpkgs = {
    overlays = [
      # Add overlays from flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      permittedInsecurePackages = [
        "electron-25.9.0" # ONLY for obsidian at the moment
      ];
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  services.k3s = {
    enable = true;
  };

  environment.pathsToLink = ["/share/zsh"];
  environment.systemPackages = with pkgs; [
    bibata-cursors-translucent
    fluent-icon-theme

    onlyoffice-bin
    jetbrains.rider
    wine
    winetricks
    gcc
    python311Packages.cmake
    nodejs_22
    microsoft-edge-dev
    xorg.xmodmap
    git
    nix-output-monitor

    bluetuith
    fastfetch
    polkit_gnome
    gnumake # for lenovo-legion
    linuxHeaders # for lenovo-legion
    dmidecode # for lenovo-legion
    lm_sensors # for lenovo-legion
    lenovo-legion
    atac
    zoxide
    ripgrep
    fd
    swappy
    easyeffects
    brightnessctl
    pulseaudio
    playerctl
    spotify
    (pkgs.discord-canary.override {
      withOpenASAR = true;
      withVencord = true;
    })
    # discord-canary # run once as vanilla if openasar error
    betterdiscordctl
    acpi

    bc
    wl-clipboard
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
    colorScheme = "custom";

    customColorScheme = {
      text = colorsRGB.blush;
      subtext = colorsRGB.white;
      sidebar-text = colorsRGB.vanilla_pear;
      main = "#00000005";
      sidebar = colorsRGB.grey;
      player = colorsRGB.black;
      card = colorsRGB.orange;
      shadow = colorsRGB.burgundy;
      selected-row = colorsRGB.blue;
      button = colorsRGB.cyan;
      button-active = colorsRGB.blue;
      button-disabled = colorsRGB.grey;
      tab-active = colorsRGB.blush;
      notification = colorsRGB.green;
      notification-error = colorsRGB.red;
      misc = colorsRGB.white_dim;
    };

    enabledCustomApps = with spicePkgs.apps; [marketplace];
    enabledExtensions = with spicePkgs.extensions; [
      keyboardShortcut
      powerBar
      shuffle # shuffle+
      skipStats
      autoVolume
      adblock
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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
    TERM = "kitty";
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
    polarity = "dark";
    base16Scheme = {
      base00 = outputs.colors.black;
      base01 = outputs.colors.grey;
      base02 = outputs.colors.orange_dim;
      base03 = outputs.colors.white_dim;
      base04 = outputs.colors.beige;
      base05 = outputs.colors.white;
      base06 = outputs.colors.cyan;
      base07 = outputs.colors.red;
      base08 = outputs.colors.blush;
      base09 = outputs.colors.burgundy;
      base0A = outputs.colors.cyan;
      base0B = outputs.colors.green;
      base0C = outputs.colors.yellow;
      base0D = outputs.colors.beige;
      base0E = outputs.colors.vanilla_pear;
      base0F = outputs.colors.orange_bright;
    };
    targets = {
      gnome.enable = true;
      gtk.enable = true;
    };

    fonts = {
      serif = {
        package = pkgs.merriweather;
        name = "Merriweather";
      };

      sansSerif = {
        package = pkgs.public-sans;
        name = "Public Sans";
      };

      monospace = {
        package = pkgs.cartograph-cf;
        name = "CartographCF Nerd Font";
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

  security.polkit.enable = true;

  # formerly hardware.opengl
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    tmp.cleanOnBoot = true;
    loader.grub.timeoutStyle = false;
    kernelParams = [
      "i915.fastboot=1"
      # "boot.shell_on_fail"
      # "rd.systemd.show_status=false"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = true;
        configurationLimit = 100;
      };
    };
  };

  # hardware.fancontrol = {
  #   enable = true;
  #   config = ''
  #     # Configuration file generated by pwmconfig
  #     INTERVAL=10
  #     DEVPATH=hwmon3=devices/virtual/thermal/thermal_zone2 hwmon4=devices/platform/f71882fg.656
  #     DEVNAME=hwmon3=soc_dts1 hwmon4=f71869a
  #     FCTEMPS=hwmon4/device/pwm1=hwmon3/temp1_input
  #     FCFANS=hwmon4/device/pwm1=hwmon4/device/fan1_input
  #     MINTEMP=hwmon4/device/pwm1=35
  #     MAXTEMP=hwmon4/device/pwm1=65
  #     MINSTART=hwmon4/device/pwm1=150
  #     MINSTOP=hwmon4/device/pwm1=0
  #   '';
  # };
  hardware.nvidia = {
    modesetting.enable = true; # Modesetting is required.

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # sync.enable = true;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

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
  console.keyMap = "sv-latin1";

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.docker.daemon.settings = {
    data-root = "~/Documents/coding/docker";
  };

  networking.hostName = "nixos";

  users.users = {
    hedonicadapter = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];
      extraGroups = ["networkmanager" "wheel" "docker" "dialout"];
    };
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  services.xremap = {
    config = {
      modmap = [
        {
          name = "Global";
          remap = {"CapsLock" = "Esc";};
          remap = {"Esc" = "CapsLock";};
        }
      ];
    };
  };

  services.logind = {lidSwitch = "ignore";};

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  # Load nvidia driver for Xorg and Wayland
  # Configure keymap in X11
  services.xserver = {
    # Enable X11 windowing system
    enable = true;

    xkb.layout = "se";
    xkb.variant = "";

    videoDrivers = ["nvidia"];

    displayManager.gdm.enable = true; # GNOME Desktop Environment
    desktopManager.gnome.enable = true;
  };
  # services.libinput.mouse.accelProfile = "adaptive"; configured in hyprland.conf
  services.printing.enable = true;
  services.thermald.enable = true;
  services.fwupd.enable = true; # Firmware updator
  services.upower.enable = true; # battery
  services.system76-scheduler.enable = true;

  # services.throttled = {
  #   enable = true;
  #   extraConfig = ''
  #     [UNDERVOLT]
  #     # CPU core voltage offset (mV)
  #     CORE: -105
  #     # Integrated GPU voltage offset (mV)
  #     GPU: -85
  #     # CPU cache voltage offset (mV)
  #     CACHE: -105
  #     # System Agent voltage offset (mV)
  #     UNCORE: -85
  #     # Analog I/O voltage offset (mV)
  #     ANALOGIO: 0
  #   '';
  # };
  # services.undervolt = {
  #   enable = true;
  #   # useTimer = true;
  #   verbose = true;
  #   uncoreOffset = -75;
  #   turbo = 0;
  #   tempAc = 70;
  #   tempBat = 65;
  #   temp = 70;
  #   p2.window = 0.002;
  #   p2.limit = 90;
  #   p1.window = 28;
  #   p1.limit = 45;
  #   gpuOffset = -50;
  #   coreOffset = -50;
  #   analogioOffset = -50;
  # };
  # systemd.services.intel-undervolt = {
  #   description = "Intel Undervolt";
  #   after = ["multi-user.target"];
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.writeShellScript "undavolt" ''
  #       #!/usr/bin/env bash
  #       PATH=$PATH:${lib.makeBinPath [pkgs.undervolt]}
  #       undervolt read & undervolt apply
  #     ''}";
  #   };
  # };
  services.power-profiles-daemon.enable = false;
  # services.auto-cpufreq = {
  #   enable = true;
  #   settings = {
  #     battery = {
  #       governor = "powersave";
  #       turbo = "never";
  #       preference = "power";
  #     };
  #     charger = {
  #       governor = "powersave";
  #       turbo = "never";
  #     };
  #   };
  # };
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # tlp diskid
      DISK_DEVICES = "nvme-CT1000P3SSD8_2321E6DAEA8C nvme-CT1000P3SSD8_2321E6DAEA8C_1 nvme-nvme.c0a9-323332314536444145413843-435431303030503353534438-00000001 ata-KINGSTON_SUV400S37240G_50026B776601F816";

      # tlp-stat -g
      INTEL_GPU_MIN_FREQ_ON_AC = 350000000;
      INTEL_GPU_MIN_FREQ_ON_BAT = 350000000;
      INTEL_GPU_MAX_FREQ_ON_AC = 900000000;
      INTEL_GPU_MAX_FREQ_ON_BAT = 800000000;
      INTEL_GPU_BOOST_FREQ_ON_AC = 1000000000;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 900000000;

      # tlp-stat -p
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # for intel-pstate
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 80;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 70;

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      USB_AUTOSUSPEND = 0;
      RESTORE_DEVICE_STATE_ON_STARTUP = true;
    };
  };

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
