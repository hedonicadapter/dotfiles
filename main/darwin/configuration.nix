{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = with inputs; [
    home-manager.darwinModules.home-manager
    stylix.darwinModules.stylix

    # ./maintenance.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    #     extraSpecialArgs = {
    #       inherit system pkgs colors-flake spicetify-nix;
    #     };
    users = {samherman1 = import ../home-manager/home.nix;};
    backupFileExtension = "backup";
    sharedModules = with inputs; [
      mac-app-util.homeManagerModules.default
      spicetify-nix.homeManagerModules.spicetify
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      # Add overlays from flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
  };

  nvim = let
    inherit (inputs.neovim-flake) utils;
    basePackage = inputs.neovim-flake.packageDefinitions.nvim or ({...}: {});
  in {
    enable = true;
    packageDefinitions = {
      merge.nvim = utils.mergeCatDefs basePackage ({pkgs, ...}: {
        extra.colors = outputs.colors;
      });
    };
  };
}
