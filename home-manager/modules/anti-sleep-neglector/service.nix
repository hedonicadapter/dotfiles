{
  config,
  pkgs,
  ...
}: {
  /*
  wlsunset -l "$LATITUDE" -L "$LONGITUDE"
  */
  systemd.user.services.anti-sleep-neglector = {
    Unit = {
      Description = "Run anti sleep neglector protocol";
    };
    Service = {
      ExecStart = "${pkgs.writeShellScriptBin "anti-sleep-neglector" ''
        ${builtins.readFile ./set-circadian-vars.sh}
      ''}/bin/anti-sleep-neglector";
      Restart = "always";
      Environment = [
        "LATITUDE=57.7"
        "LONGITUDE=12"
        "WALLPAPERS_DIR=${config.home.homeDirectory}/Pictures/wallpapers"
      ];
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # To access the variables in your shell sessions:
  programs.zsh.initExtra = ''
    function get_sun_var() {
      systemctl --user show-environment | grep "^$1=" | cut -d= -f2-
    }
    alias update_sun_vars='export FIRST_LIGHT=$(get_sun_var FIRST_LIGHT) DAWN=$(get_sun_var DAWN) SUNRISE=$(get_sun_var SUNRISE) SOLAR_NOON=$(get_sun_var SOLAR_NOON) SUNSET=$(get_sun_var SUNSET) LAST_LIGHT=$(get_sun_var LAST_LIGHT) CURRENT_TIME=$(get_sun_var CURRENT_TIME)'
  '';
}
