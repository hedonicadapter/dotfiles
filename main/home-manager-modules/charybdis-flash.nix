# Flashes the latest CI firmware onto Charybdis halves that enter bootloader
# mode. Runs as the user for its `gh auth` login and udisks mounting.
# Once per half: `charybdis-flash learn left|right`
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  flash = pkgs.writeShellApplication {
    name = "charybdis-flash";
    runtimeInputs = with pkgs; [
      gh
      udisks # udisksctl
      util-linux # lsblk, findmnt
      systemd # udevadm
      coreutils
      gawk
      gnused
      libnotify
    ];
    text = builtins.readFile "${inputs.charybdis-firmware}/scripts/flash.sh";
  };
in {
  home.packages = [flash];

  systemd.user.services.charybdis-flash = {
    Unit.Description = "Flash Charybdis halves in bootloader mode";
    Service = {
      ExecStart = "${lib.getExe flash} watch";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
