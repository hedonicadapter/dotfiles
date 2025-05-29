{
  description = "Best thing ever";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
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
    ags.url = "github:aylur/ags";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";

    stylix.url = "github:danth/stylix/ed91a20c84a80a525780dcb5ea3387dddf6cd2de";
    swww.url = "github:LGFae/swww";
    nur.url = "github:nix-community/NUR";
    matugen.url = "github:/InioX/Matugen";
    xremap-flake.url = "github:xremap/nix-flake";
    nixcord.url = "github:kaylorben/nixcord";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    colors,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux" "aarch64-darwin"];
    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    overlays = import ./overlays {inherit inputs;}; # Your custom packages and modifications, exported as overlays

    inherit (colors.outputs) transparentize darken cssColorVariables hexColorTo0xAARRGGBB;
    palette = builtins.fromJSON (builtins.readFile ./palette.json);
    palette_opaque = builtins.fromJSON (builtins.readFile ./palette.json);

    nixosConfigurations."default" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs outputs;};

      modules = with inputs; [
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        nixos-hardware.nixosModules.common-pc-laptop-hdd
        neovim-flake.nixosModules.default
        ./nixos/configuration.nix
        chaotic.nixosModules.default
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
