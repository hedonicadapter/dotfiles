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

  };

  outputs = { self, nixpkgs, spicetify-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

      devShell.x86_64-linux = (import ./shell.nix { inherit pkgs; });
    };
}
