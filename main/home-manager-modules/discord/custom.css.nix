{outputs, ...}: let
  # @name base16 3024
  # @author Jan T. Sott (http://github.com/idleberg)
  # @version 1.0.0
  # @description base16 3024 theme generated from https://github.com/tinted-theming/schemes
  # base16 structure from deathbeam/base16-discord
  css = ''
    :root {
        --base00: ${outputs.palette.base00};
        --base01: ${outputs.palette.base01};
        --base02: ${outputs.palette.base02};
        --base03: ${outputs.palette.base03};
        --base04: ${outputs.palette.base04};
        --base05: ${outputs.palette.base05};
        --base06: ${outputs.palette.base06};
        --base07: ${outputs.palette.base07};
        --base08: ${outputs.palette.base08};
        --base09: ${outputs.palette.base09};
        --base0A: ${outputs.palette.base0A};
        --base0B: ${outputs.palette.base0B};
        --base0C: ${outputs.palette.base0C};
        --base0D: ${outputs.palette.base0D};
        --base0E: ${outputs.palette.base0E};
        --base0F: ${outputs.palette.base0F};

        --primary-630: var(--base00); /* Autocomplete background */
        --primary-660: var(--base00); /* Search input background */
    }

    .theme-light, .theme-dark {
        --search-popout-option-fade: none; /* Disable fade for search popout */
        --bg-overlay-2: var(--base00); /* These 2 are needed for proper threads coloring */
        --home-background: var(--base00);
        --background-primary: var(--base00);
        --background-secondary: var(--base01);
        --background-secondary-alt: var(--base01);
        --channeltextarea-background: var(--base01);
        --background-tertiary: var(--base00);
        --background-accent: var(--base0E);
        --background-floating: var(--base01);
        --background-modifier-selected: var(--base00);
        --text-normal: var(--base05);
        --text-secondary: var(--base00);
        --text-muted: var(--base03);
        --text-link: var(--base0C);
        --interactive-normal: var(--base05);
        --interactive-hover: var(--base0C);
        --interactive-active: var(--base0A);
        --interactive-muted: var(--base03);
        --header-primary: var(--base06);
        --header-secondary: var(--base03);
        --scrollbar-thin-track: transparent;
        --scrollbar-auto-track: transparent;
    }
  '';
in
  css
