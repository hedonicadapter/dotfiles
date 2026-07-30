{
  outputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xwayland-satellite
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
