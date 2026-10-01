# Hand-written for Ryzen 7 9800X3D / Asus TUF B850I, same SSD as laptop.
# Replace with `nixos-generate-config --show-hardware-config` output after first boot.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "thunderbolt" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/abdd773a-34d4-4e10-9a26-0d68a92dcf76";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8E79-73D2";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
      randomEncryption.enable = true;
    }
  ];

  networking.useDHCP = lib.mkDefault true;
  # Wake-on-LAN: NIC name unknown until first boot, check `ip link`
  # networking.interfaces.<name>.wakeOnLan.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
