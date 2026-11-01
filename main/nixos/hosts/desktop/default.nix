# Desktop: Ryzen 7 9800X3D (iGPU until RX 9060 XT arrives), Asus TUF B850I
{
  config,
  lib,
  pkgs,
  ...
}: let
  wm = lib.getExe pkgs.wm;
  # Stay up while someone is in over SSH. Media players and games hold compositor
  # idle inhibitors, so swayidle never gets this far while they play.
  idleSuspend = pkgs.writeShellScript "idle-suspend" ''
    ${pkgs.iproute2}/bin/ss -Htn state established '( sport = :22 )' | ${pkgs.gnugrep}/bin/grep -q . && exit 0
    ${pkgs.systemd}/bin/systemctl suspend
  '';
in {
  imports = [./hardware-configuration.nix];

  home-manager.extraSpecialArgs.display = import ./display.nix;

  networking.hostName = "desktop";

  # Motherboard sensors (NCT6799: fans, voltages)
  boot.kernelModules = ["nct6775"];

  # HDMI 2.1 FRL (>18 Gb/s, needed for 240 Hz): off by default until 7.4.
  # 0x400 = DC_FRL_MASK, 0x2 = upstream default (multi-mon mclk switch) kept.
  # Drop once kernel >= 7.4 enables FRL by default.
  boot.kernelParams = ["amdgpu.dcfeaturemask=0x402"];
  assertions = [
    {
      assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "7.2";
      message = "amdgpu HDMI 2.1 FRL needs kernel >= 7.2; run `nix flake update nix-cachyos-kernel`.";
    }
  ];

  # GPU fan/power/clock control, works for iGPU and RX 9060 XT
  services.lact.enable = true;

  # Projector colour and dimming follow the LIFX "home" group (niri)
  home-manager.users.hedonicadapter.services.anti-sleep-neglector-lifx.enable = true;
  # Bulbs answer broadcasts from their own IP, which conntrack never matches
  networking.firewall.allowedUDPPorts = [
    config.home-manager.users.hedonicadapter.services.anti-sleep-neglector-lifx.port
  ];

  # Suspend + Wake-on-LAN instead of running 24/7; shared config keeps sleep off for the laptop
  systemd.sleep.settings.Sleep.AllowSuspend = lib.mkForce "yes";
  # Idle: monitors off after 10 min, suspend after 30. Wake by power button or magic packet;
  # the Bluetooth keyboard can't wake from suspend.
  home-manager.users.hedonicadapter.services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "${wm} monitors off";
        resumeCommand = "${wm} monitors on";
      }
      {
        timeout = 1800;
        command = "${idleSuspend}";
      }
    ];
    # Compositor leaves outputs off after resume until it sees input
    events.after-resume = "${wm} monitors on";
  };
  # Magic-packet wake on every connection NetworkManager activates; flag values differ per type.
  # Also needs BIOS: APM Configuration → Power On By PCI-E enabled, ErP disabled.
  networking.networkmanager.connectionConfig = {
    "ethernet.wake-on-lan" = 64; # magic
    # MT7922 WoWLAN; only from suspend, and the router must keep the sleeping client associated
    "wifi.wake-on-wlan" = 8; # magic
  };
}
