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
  };
}
