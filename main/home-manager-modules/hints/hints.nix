{
  pkgs,
  outputs,
  config,
  ...
}: let
  hintsPkg = pkgs.callPackage ./hints-derivation.nix {};
in {
  home.packages = [hintsPkg];

  systemd.user.services.hintsd = {
    Unit = {
      Description = "Hints daemon";
      After = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${hintsPkg}/bin/hintsd";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };

  home.file = {
    ".config/hints/config.json".text = import ./config.json.nix {inherit outputs config;};
    # "etc/udev/rules.d/80-hints.rules".text = ''KERNEL=="uinput", GROUP="input", MODE:="0660"''; # INFO: home manager is only for user-space config, create this with services.udev.extraRules instead
  };

  home.sessionVariables = {
    ACCESSIBILITY_ENABLED = "1";
    GTK_MODULES = "gail:atk-bridge";
    OOO_FORCE_DESKTOP = "gnome";
    GNOME_ACCESSIBILITY = "1";
    QT_ACCESSIBILITY = "1";
    QT_LINUX_ACCESSIBILITY_ALWAYS_ON = "1";
  };
}
