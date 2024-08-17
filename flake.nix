{
  description = "Best thing ever";

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

    darkenColor = color: amount: let
      inherit (nixpkgs.lib) stringToCharacters toHexString;
      chars = stringToCharacters color;
      r = toHexString (builtins.sub (builtins.fromTOML "0x${builtins.substring 1 2 color}") amount);
      g = toHexString (builtins.sub (builtins.fromTOML "0x${builtins.substring 3 2 color}") amount);
      b = toHexString (builtins.sub (builtins.fromTOML "0x${builtins.substring 5 2 color}") amount);
    in "#${r}${g}${b}";

    colors = {
      black = "#0F1F1F";
      grey = "#292828";
      red = "#E8786D";
      red_dim = "#af7070";
      burgundy = "#835353";
      yellow = "#FFE4B3";
      yellow_dim = "#E8A86D";
      orange = "#E8A86D";
      orange_dim = "#9c705e";
      orange_bright = "#ff78a7";
      green = "#D4D4D4";
      green_dim = "#A6A6A6";
      blue = "#cfcfcf";
      blue_dim = "#8f5b56";
      blush = "#ff78a7";
      cyan = "#706767";
      cyan_dim = "#4b4b4b";
      white = "#f5f5f5";
      white_dim = "#D4D4D4";
      beige = "#FFE4B3";
      vanilla_pear = "#ffa885";
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

    isOpaque = color:
      builtins.stringLength color == 7 && builtins.substring 0 1 color == "#";

    colors_opaque = builtins.listToAttrs (
      builtins.filter (x: isOpaque (builtins.getAttr x.name colors))
      (builtins.map (name: {
          inherit name;
          value = builtins.getAttr name colors;
        })
        (builtins.attrNames colors))
    );

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
    colors_opaque = colors_opaque;
    darkenColor = darkenColor;
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
