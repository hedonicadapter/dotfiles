{
  description = "Best thing ever";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    hyprland.type = "git";
    hyprland.url = "https://github.com/hyprwm/Hyprland";
    hyprland.submodules = true;

    split-monitor-workspaces.url = "github:Duckonaut/split-monitor-workspaces";
    split-monitor-workspaces.inputs.hyprland.follows = "hyprland";

    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    colors.url = "github:hedonicadapter/colors-flake";
    neovim-flake.url = "github:hedonicadapter/neovim-config-flake";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
    ags.url = "github:aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    swww.url = "github:LGFae/swww";
    nur.url = "github:nix-community/NUR";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    xremap-flake.url = "github:xremap/nix-flake";
    nixcord.url = "github:kaylorben/nixcord";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    direnv-instant.url = "github:Mic92/direnv-instant";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    colors,
    nix-cachyos-kernel,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux" "aarch64-darwin"];
    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    overlays = import ./overlays {inherit inputs outputs;}; # Your custom packages and modifications, exported as overlays

    inherit (colors.outputs) transparentize darken cssColorVariables hexColorTo0xAARRGGBB isDarkColor;
    palette = builtins.fromJSON (builtins.readFile ./palette.json);
    paletteOpaque = builtins.fromJSON (builtins.readFile ./palette.json);

    nixosConfigurations."default" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs outputs;};

      modules = with inputs; [
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        nixos-hardware.nixosModules.common-pc-laptop-hdd
        ./nixos/configuration.nix
      ];
    };

    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs outputs;};

      modules = with inputs; [
        home-manager.darwinModules.home-manager
        mac-app-util.darwinModules.default
        stylix.darwinModules.stylix
        neovim-flake.nixosModules.default
        ./darwin/configuration.nix
      ];
    };
  };
}
