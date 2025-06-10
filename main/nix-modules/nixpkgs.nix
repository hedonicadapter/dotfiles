{outputs}: {
  nixpkgs = {
    overlays = [
      # Add overlays from flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      permittedInsecurePackages = [
        "electron-25.9.0" # ONLY for obsidian at the moment
        "dotnet-sdk-wrapped-6.0.428"
      ];
      allowUnfree = true;
    };
  };
}
