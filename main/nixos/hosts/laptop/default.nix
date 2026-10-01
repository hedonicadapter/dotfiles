# Lenovo Legion laptop: Intel CPU + Nvidia dGPU (PRIME offload)
{
  config,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  networking.hostName = "nixos";

  environment.systemPackages = with pkgs; [
    gnumake # for lenovo-legion
    linuxHeaders # for lenovo-legion
    dmidecode # for lenovo-legion
    lenovo-legion
    acpi
    brightnessctl
  ];

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
    nvidia-vaapi-driver

    intel-vaapi-driver # i965
    libvdpau-va-gl
  ];

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
      # "nvidia_drm.fbdev=1"
      # "i915.fastboot=1"
      # "boot.shell_on_fail"
      # "rd.systemd.show_status=false"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"
      "acpi_enforce_resources=lax" # GDM/UCSI fix for older Lenovo ACPI bugs
    ];

    blacklistedKernelModules = ["ucsi_ccg"];
  };

  systemd.services.nvidia-powerd.enable = true;
  hardware.nvidia = {
    modesetting.enable = true; # Modesetting is required.

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

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

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Built-in keyboard only
  xremapCapsEsc.devices = ["AT Translated Set 2 keyboard" "ITE Tech. Inc. ITE Device(8910) Keyboard"];

  services.logind = {lidSwitch = "ignore";};

  services.thermald.enable = true;
  services.upower.enable = true; # battery

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
      CPU_MAX_PERF_ON_AC = 85;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 70;

      CPU_BOOST_ON_AC = 1;
      NVIDIA_GPU_PERF_LEVEL_ON_AC = "high";

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      USB_DENYLIST = "8087:0aaa";
      USB_EXCLUDE_BTUSB = 1;
      USB_AUTOSUSPEND = 0;
      RESTORE_DEVICE_STATE_ON_STARTUP = true;
    };
  };
}
