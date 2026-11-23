# Play a sound when a Bluetooth device connects or disconnects
{
  pkgs,
  session,
  ...
}: let
  # Device1 PropertiesChanged, one line each, e.g.
  # /org/bluez/hci0/dev_XX: org.freedesktop.DBus.Properties.PropertiesChanged ('org.bluez.Device1', {'Connected': <true>}, @as [])
  watch = pkgs.writeShellApplication {
    name = "bluetooth-sounds";
    runtimeInputs = [pkgs.glib];
    text = ''
      gdbus monitor --system --dest org.bluez | while IFS= read -r line; do
        case $line in
          *"'org.bluez.Device1'"*"'Connected': <true>"*) ${session.sounds.bluetoothConnect} & ;;
          *"'org.bluez.Device1'"*"'Connected': <false>"*) ${session.sounds.bluetoothDisconnect} & ;;
        esac
      done
    '';
  };
in {
  systemd.user.services.bluetooth-sounds = {
    Unit = {
      Description = "Play a sound when a Bluetooth device connects or disconnects";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${watch}/bin/bluetooth-sounds";
      # gdbus exits if the system bus goes away
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
