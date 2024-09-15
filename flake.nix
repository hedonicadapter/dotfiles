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

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # color utils
    nix-colors = {url = "github:misterio77/nix-colors";};

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
    nix-colors,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux"];
    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs systems;

    colors = {
      black = "#2b3339"; # base00
      grey = "#323c41"; # base01
      red = "#7fbbb3"; # base08
      red_dim = "#e67e80"; # base0E
      burgundy = "#503946"; # base02
      yellow = "#83c092"; # base0A
      yellow_dim = "#fff9e8"; # base07
      orange = "#d699b6"; # base09
      orange_dim = "#d699b6"; # base0F
      orange_bright = "#d699b6"; # base09
      green = "#dbbc7f"; # base0B
      green_dim = "#e9e8d2"; # base06
      blue = "#a7c080"; # base0D
      blue_dim = "#e69875"; # base0C
      blush = "#7fbbb3"; # base08
      cyan = "#e69875"; # base0C
      cyan_dim = "#a7c080"; # base0D
      white = "#d3c6aa"; # base05
      white_dim = "#fff9e8"; # base07
      beige = "#fff9e8"; # base07
      vanilla_pear = "#d3c6aa"; # base05
    };

    sanitizeColor = color:
      if builtins.substring 0 1 color == "#"
      then builtins.substring 1 (builtins.stringLength color - 1) color
      else color;

    rgbToHex = r: g: b: let
      toHex = x: let
        hex = nixpkgs.lib.toHexString (builtins.floor x);
      in
        if builtins.stringLength hex == 1
        then "0${hex}"
        else hex;
    in "#${toHex r}${toHex g}${toHex b}";

    darken = let
      darkenColor = color: percentage: let
        cleanColor = sanitizeColor color;
        rgb = nix-colors.lib.conversions.hexToRGB cleanColor;

        darken = c: let
          darkenedValue = c - (c * percentage);
        in
          builtins.floor darkenedValue;

        darkenedRgb = {
          r = darken (builtins.elemAt rgb 0);
          g = darken (builtins.elemAt rgb 1);
          b = darken (builtins.elemAt rgb 2);
        };
      in
        rgbToHex darkenedRgb.r darkenedRgb.g darkenedRgb.b;
    in
      darkenColor;

    transparentize = let
      addAlpha = color: alpha: let
        alphaInt = builtins.floor (alpha * 255);
        alphaHex = builtins.substring 0 2 (builtins.toString (100 + alphaInt));

        cleanColor = sanitizeColor color;
        rgb = nix-colors.lib.conversions.hexToRGB cleanColor;
      in
        (rgbToHex (builtins.elemAt rgb 0) (builtins.elemAt rgb 1) (builtins.elemAt rgb 2)) + alphaHex;
    in
      addAlpha;

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
    transparentize = transparentize;
    darken = darken;
    colors_opaque = colors_opaque;
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
