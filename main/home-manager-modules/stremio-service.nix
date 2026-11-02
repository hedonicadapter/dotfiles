# Stremio's streaming server as a user service, so web.stremio.com in the
# browser gets its remux/transcode backend on 127.0.0.1:11470 without the
# desktop app open. nixpkgs wraps it with --skip-updater and jellyfin-ffmpeg;
# it also puts a StatusNotifier icon in the tray (AGS shows it).
#
# stremio-linux-shell starts its own server.js on the same port; with this
# running, that one fails to bind and the app uses this server instead.
{pkgs, ...}: {
  home.packages = [pkgs.stremio-service];

  systemd.user.services.stremio-service = {
    Unit = {
      Description = "Stremio streaming server (127.0.0.1:11470)";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.stremio-service}/bin/stremio-service";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
