# Desktop: Ryzen 7 9800X3D (iGPU until RX 9060 XT arrives), Asus TUF B850I
{pkgs, ...}: let
  lifxPort = 56701;
in {
  imports = [./hardware-configuration.nix];

  networking.hostName = "desktop";

  # Motherboard sensors (NCT6799: fans, voltages)
  boot.kernelModules = ["nct6775"];

  # GPU fan/power/clock control, works for iGPU and RX 9060 XT
  services.lact.enable = true;

  # RGB control; CPU cooler fan is on the motherboard ARGB header
  services.hardware.openrgb = {
    enable = true;
    # No SMBus driver; only the USB Aura controller is wanted
    motherboard = null;
    # B850 Aura controller (0b05:1cd2) not yet upstream; same protocol as older boards
    package = pkgs.openrgb.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          sed -i '/AURA_MOTHERBOARD_5_PID);/a REGISTER_HID_DETECTOR("ASUS Aura Motherboard", DetectAsusAuraUSBMotherboards, AURA_USB_VID, 0x1CD2);' \
            Controllers/AsusAuraUSBController/AsusAuraUSBControllerDetect.cpp
          grep -q 0x1CD2 Controllers/AsusAuraUSBController/AsusAuraUSBControllerDetect.cpp
        '';
    });
  };

  # Only USB HID (Aura controller) reachable: blocks SMBus RAM probing
  # (/dev/i2c-*) and Super I/O port access (/dev/port), which have
  # corrupted RAM RGB controllers in the past
  systemd.services.openrgb.serviceConfig = {
    DevicePolicy = "closed";
    DeviceAllow = ["char-hidraw rw" "char-usb_device rw"];
  };

  # Cooler fan follows LIFX lamp color over LAN
  systemd.services.lifx-rgb-sync = {
    description = "Mirror LIFX lamp color to OpenRGB";
    after = ["openrgb.service" "network-online.target"];
    wants = ["network-online.target"];
    requires = ["openrgb.service"];
    wantedBy = ["multi-user.target"];
    environment = {
      LIFX_PORT = toString lifxPort;
      # 2x TL-C12B-S V2 fans on one ARGB header via splitter, ~8 LEDs each
      OPENRGB_LEDS = "16";
      # LIFX_LABEL = "Desk"; # follow a specific lamp
    };
    serviceConfig = {
      ExecStart = "${pkgs.python3.withPackages (p: [p.openrgb-python])}/bin/python ${./lifx-rgb-sync.py}";
      DynamicUser = true;
      Restart = "always";
      RestartSec = 10;
    };
  };

  # LIFX lamps reply to broadcast from their own IP, which conntrack doesn't match
  networking.firewall.allowedUDPPorts = [lifxPort];
}
