{
  description = "Nixos config flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    hyprland = { url = "github:hyprwm/Hyprland"; };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = { url = "github:Aylur/ags"; };

    spicetify-nix = { url = "github:the-argus/spicetify-nix"; };

    nixneovimplugins = { url = "github:jooooscha/nixpkgs-vim-extra-plugins"; };

    stylix = { url = "github:danth/stylix"; };
  };

  outputs = { self, nixpkgs, spicetify-nix, stylix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          stylix.nixosModules.stylix
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

      # devShell.x86_64-linux = (import ./shell.nix { inherit pkgs; });

      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [
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
