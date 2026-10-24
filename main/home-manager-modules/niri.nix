{
  outputs,
  pkgs,
  osConfig,
  ...
}: let
  # Folds new windows into existing columns instead of scrolling sideways
  autotile =
    pkgs.writers.writePython3Bin "niri-autotile" {flakeIgnore = ["E501"];}
    (builtins.readFile ./niri/autotile.py);
in {
  home.packages = [
    pkgs.xwayland-satellite
    autotile
  ];

  systemd.user.services.niri-autotile = {
    Unit = {
      Description = "Fold new niri windows into existing columns";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
      # Skip under Hyprland
      ConditionEnvironment = "NIRI_SOCKET";
    };
    Service = {
      ExecStart = "${autotile}/bin/niri-autotile";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  home.file = {
    ".config/niri/config.kdl".text = import ./niri/config.kdl.nix {
      inherit outputs;
      inherit (osConfig.networking) hostName;
    };

    # Nvidia driver doesn't release VRAM back to the pool — niri creeps toward 1 GiB
    # instead of ~100 MiB. GLVidHeapReuseRatio=0 caps the free buffer pool.
    # https://github.com/niri-wm/niri/wiki/Nvidia
    ".nv/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".source =
      ./niri/nvidia-application-profiles.json;
  };
}
