{outputs, ...}: let
  # @name base16 3024
  # @author Jan T. Sott (http://github.com/idleberg)
  # @version 1.0.0
  # @description base16 3024 theme generated from https://github.com/tinted-theming/schemes
  # base16 structure from deathbeam/base16-discord
  css = ''
    :root {
        --base00: ${outputs.transparentize outputs.colors.black 0.4};
        --base01: ${outputs.transparentize outputs.colors.grey 0.6};
        --base02: ${outputs.colors.burgundy};
        --base03: ${outputs.colors.orange_bright};
        --base04: ${outputs.colors.cyan};
        --base05: ${outputs.colors.white};
        --base06: ${outputs.colors.green_dim};
        --base07: ${outputs.colors.beige};
        --base08: ${outputs.colors.red};
        --base09: ${outputs.colors.orange};
        --base0A: ${outputs.colors.yellow};
        --base0B: ${outputs.colors.green};
        --base0C: ${outputs.colors.green_dim};
        --base0D: ${outputs.colors.blue};
        --base0E: ${outputs.colors.red_dim};
        --base0F: ${outputs.colors.orange_dim};

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
