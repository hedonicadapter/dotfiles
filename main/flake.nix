{
  description = "Best thing ever";

  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-unstable";};

    nixos-hardware = {url = "github:NixOS/nixos-hardware/master";};

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colors = {
      url = "github:hedonicadapter/colors-flake";
    };

    neovim-config = {
      url = "github:hedonicadapter/neovim-config-flake";
    };

    ags = {
      url = "github:aylur/ags";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/ed91a20c84a80a525780dcb5ea3387dddf6cd2de";
    };

    swww = {url = "github:LGFae/swww";};

    nur = {url = "github:nix-community/NUR";};

    matugen = {
      url = "github:/InioX/Matugen";
    };

    xremap-flake = {
      url = "github:xremap/nix-flake";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    colors,
    chaotic,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux"];
    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays = import ./overlays {inherit inputs;}; # Your custom packages and modifications, exported as overlays

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    colors = colors.outputs.colors;
    transparentize = colors.outputs.transparentize;
    darken = colors.outputs.darken;
    colors_opaque = colors.outputs.colors_opaque;
    cssColorVariables = colors.outputs.cssColorVariables;

    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};

        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-pc-laptop-hdd
          ./nixos/configuration.nix
          chaotic.nixosModules.default
        ];
      };
    };

    devShell.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
        # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
        gst_all_1.gstreamer
        # Common plugins like "filesrc" to combine within e.g. gst-launch
        gst_all_1.gst-plugins-base
        # Specialized plugins separated by quality
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        # Plugins to reuse ffmpeg to play almost every video format
        gst_all_1.gst-libav
        # Support the Video Audio (Hardware) Acceleration API
        gst_all_1.gst-vaapi
        #...
      ];
    };
  };
}
