# Desktop: Ryzen 7 9800X3D (iGPU until RX 9060 XT arrives), Asus TUF B850I
{...}: {
  imports = [./hardware-configuration.nix];

  networking.hostName = "desktop";

  # Motherboard sensors (NCT6799: fans, voltages)
  boot.kernelModules = ["nct6775"];

  # GPU fan/power/clock control, works for iGPU and RX 9060 XT
  services.lact.enable = true;
}
