{
  outputs,
  inputs,
  config,
  ...
}: {
  nvim = let
    inherit (inputs.neovim-flake) utils;
    basePackage = inputs.neovim-flake.packageDefinitions.nvim or ({...}: {});
  in {
    enable = true;
    packageDefinitions = {
      merge.nvim = utils.mergeCatDefs basePackage ({pkgs, ...}: {
        extra.font = config.stylix.fonts.monospace.name;
        extra.palette = outputs.palette;
        extra.palette_opaque = outputs.paletteOpaque;

        extra.contrast =
          if outputs.isDarkColor outputs.paletteOpaque.base00
          then 0.5
          else -0.8;

        extra.modeColors = {
          n = outputs.paletteOpaque.base03;
          i = outputs.paletteOpaque.base0F;

          c = outputs.paletteOpaque.base0E;
          C = outputs.paletteOpaque.base0E;

          v = outputs.paletteOpaque.base0C;
          V = outputs.paletteOpaque.base0C;

          r = outputs.paletteOpaque.base0E;
          R = outputs.paletteOpaque.base0E;

          s = outputs.paletteOpaque.base0E;
          S = outputs.paletteOpaque.base0E;

          y = outputs.paletteOpaque.base0D;
        };
      });
    };
  };
}
