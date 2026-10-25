# Desktop: Ryzen 7 9800X3D (iGPU until RX 9060 XT arrives), Asus TUF B850I
{
  config,
  lib,
  ...
}: {
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

  # Suspend + Wake-on-LAN instead of running 24/7; shared config keeps sleep off for the laptop
  systemd.sleep.settings.Sleep.AllowSuspend = lib.mkForce "yes";
  # Magic-packet wake on every wired connection NetworkManager activates (64 = magic).
  # Also needs BIOS: APM Configuration → Power On By PCI-E enabled, ErP disabled.
  networking.networkmanager.connectionConfig."ethernet.wake-on-lan" = 64;
}
