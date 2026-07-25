{pkgs, ...}: {
  # Script lives in pkgs/stay-awake (also referenced by aerospace.nix and claude-code.nix)
  home.packages = [pkgs.stay-awake];
}
