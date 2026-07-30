{
  outputs,
  pkgs,
  ...
}: {
  home.packages = [pkgs.omniwm];

  # Canonical settings path; OmniWM live-reloads it on save. It's a store symlink,
  # and OmniWM saves atomically, so a GUI settings change replaces the symlink with
  # a plain file. It survives until the next switch, which moves it to
  # settings.toml.backup and restores this one. Treat the nix as the source of truth.
  home.file.".config/omniwm/settings.toml".text =
    import ./omniwm/settings.toml.nix {inherit outputs;};

  # OmniWM needs Accessibility (and Input Monitoring for a Hyper trigger).
  # macOS grants that per binary path, so every version bump re-prompts.
  launchd.agents.omniwm = {
    enable = true;
    config = {
      Program = "${pkgs.omniwm}/Applications/OmniWM.app/Contents/MacOS/OmniWM";
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/omniwm.log";
      StandardErrorPath = "/tmp/omniwm.err.log";
    };
  };
}
