{
  description = "Best thing ever";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.follows = "nixpkgs";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-stable-nixos.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-stable-darwin";

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

    home-manager-stable.url = "github:nix-community/home-manager/release-26.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable-darwin";

    colors.url = "github:hedonicadapter/colors-flake";
    neovim-flake.url = "github:hedonicadapter/neovim-config-flake";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
    ags.url = "github:aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";

    stylix.url = "github:nix-community/stylix/release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    swww.url = "github:LGFae/swww";
    nur.url = "github:nix-community/NUR";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    xremap-flake.url = "github:xremap/nix-flake";
    nixcord.url = "github:kaylorben/nixcord";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    direnv-instant.url = "github:Mic92/direnv-instant";
    # hermes-agent.url = "github:NousResearch/hermes-agent";
    # hermes-agent.inputs.nixpkgs.follows = "nixpkgs";

    # sops-nix.url = "github:Mic92/sops-nix";
    # sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    colors,
    nix-cachyos-kernel,
    # hermes-agent,
    # sops-nix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux" "aarch64-darwin"];
    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;
    overlays' = import ./overlays {inherit inputs outputs;};
    commonNixpkgsConfig = {
      overlays = [
        overlays'.additions
        overlays'.modifications
        overlays'.unstable-packages
        inputs.nur.overlays.default
      ];
      config = {
        permittedInsecurePackages = [
          "google-chrome-144.0.7559.97"
        ];
        allowUnfree = true;
      };
    };
    mkPkgs = nixpkgsInput: system:
      import nixpkgsInput (commonNixpkgsConfig // {inherit system;});
    darwinPkgs = mkPkgs inputs.nixpkgs-stable-darwin "aarch64-darwin";
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    overlays = overlays'; # Your custom packages and modifications, exported as overlays

    inherit (colors.outputs) transparentize darken cssColorVariables hexColorTo0xAARRGGBB isDarkColor;
    palette = builtins.fromJSON (builtins.readFile ./palette.json);
    paletteOpaque = builtins.fromJSON (builtins.readFile ./palette.json);

    nixosConfigurations."default" = inputs.nixpkgs-stable-nixos.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs outputs;};

      modules = with inputs; [
        {
          nixpkgs.overlays = commonNixpkgsConfig.overlays;
          nixpkgs.config = commonNixpkgsConfig.config;
        }
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        nixos-hardware.nixosModules.common-pc-laptop-hdd
        # sops-nix.nixosModules.sops
        # hermes-agent.nixosModules.default
        ./nixos/configuration.nix
      ];
    };

    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs outputs;};
      pkgs = darwinPkgs;

      modules = with inputs; [
        home-manager-stable.darwinModules.home-manager
        mac-app-util.darwinModules.default
        stylix.darwinModules.stylix
        neovim-flake.nixosModules.default
        # sops-nix.darwinModules.sops
        ./darwin/configuration.nix
      ];
    };
  };
}
