{
  outputs,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.xwayland-satellite

    # Folds new windows into existing columns instead of scrolling sideways
    (pkgs.writers.writePython3Bin "niri-autotile" {flakeIgnore = ["E501"];}
      (builtins.readFile ./niri/autotile.py))
  ];

  home.file = {
    ".config/niri/config.kdl".text = import ./niri/config.kdl.nix {inherit outputs;};
    ".config/niri/auto-start.sh".source = ./niri/auto-start.sh;

    # Nvidia driver doesn't release VRAM back to the pool — niri creeps toward 1 GiB
    # instead of ~100 MiB. GLVidHeapReuseRatio=0 caps the free buffer pool.
    # https://github.com/niri-wm/niri/wiki/Nvidia
    ".nv/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".source =
      ./niri/nvidia-application-profiles.json;
  };
}
