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
  nix.gc = {
    automatic = true;
    dates = "19:10";
    options = "--delete-older-than 30d";
  };
  nix.optimise = {
    automatic = true;
    dates = ["19:20"];
  };
}
