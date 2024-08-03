{inputs, ...}: {
  system.autoUpgrade = {
    enable = true;
    dates = "19:00";
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
  };
}
