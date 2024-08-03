{
  description = "Your new nix config";

  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-unstable";};

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

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

    ags = {url = "github:Aylur/ags";};

    spicetify-nix = {url = "github:the-argus/spicetify-nix";};

    nixneovimplugins = {url = "github:jooooscha/nixpkgs-vim-extra-plugins";};

    stylix = {url = "github:danth/stylix";};

    swww = {url = "github:LGFae/swww";};

    nur = {url = "github:nix-community/NUR";};

    matugen = {
      url = "github:/InioX/Matugen";
      # ref = "refs/tags/matugen-v0.10.0";
    };

    awesome-neovim-plugins = {
      url = "github:m15a/flake-awesome-neovim-plugins";
    };

    xremap-flake = {
      url = "github:xremap/nix-flake";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    colors = {
      black = "#14181a";
      grey = "#282828";
      red = "#d75f5f";
      red_dim = "#ba3d3d";
      burgundy = "#b16286";
      yellow = "#d69617";
      yellow_dim = "#cea64a";
      orange = "#d65d0e";
      orange_dim = "#e78a4e";
      orange_bright = "#e78a4e";
      green = "#a8a81c";
      green_dim = "#8b9553";
      blue = "#458588";
      blue_dim = "#83a598";
      blush = "#d3869b";
      cyan = "#689d6a";
      cyan_dim = "#87af87";
      white = "#dfbf8e";
      white_dim = "#d5c4a1";
      beige = "#bdae93";
      vanilla_pear = "#a89984";
      # black = "#261C1E";
      # grey = "#3A2624";
      # red = "#E94554";
      # red_dim = "#A45A49";
      # burgundy = "#8E646B";
      # yellow = "#EFC764";
      # yellow_dim = "#FEECCB";
      # orange = "#E68E7B";
      # orange_dim = "#A45A49";
      # orange_bright = "#E68E7B";
      # green = "#67E480";
      # green_dim = "#B3DFD3";
      # blue = "#97D4D9";
      # blue_dim = "#55EDC4";
      # blush = "#feafbe";
      # cyan = "#55EDC4";
      # cyan_dim = "#97D4D9";
      # white = "#FFF2E7";
      # white_dim = "#FEECCB";
      # beige = "#FEECCB";
      # vanilla_pear = "#FFF2E7";

      # melliflluous alduin
      # black = "#292828";
      # grey = "#2A2828";
      # red = "#af5f5f";
      # red_dim = "#713E3E";
      # burgundy = "#875f5f";
      # yellow = "#ffdf87";
      # yellow_dim = "#A38E56";
      # orange = "#af5f00";
      # orange_dim = "#af875f";
      # orange_bright = "#ff8000";
      # green = "#87875f";
      # green_dim = "#56563D";
      # blue = "#569cd6";
      # blue_dim = "#39658A";
      # blush = "#af8787";
      # cyan = "#87afaf";
      # cyan_dim = "#567070";
      # white = "#FFEFC2";
      # white_dim = "#877F68";
      # beige = "#dfaf87";
      # vanilla_pear = "#dfdfaf";
    };

    colorNames = builtins.attrNames colors;
    cssColorVariables = builtins.concatStringsSep "\n" (
      builtins.map (color: "--color-${color}: ${colors.${color}};") colorNames
    );
  in {
    # Accessible through 'nix build', 'nix shell', etc
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;

    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    colors = colors;
    cssColorVariables = cssColorVariables;

    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};

        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-pc-laptop-hdd
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
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
