{
  lib,
  config,
  ...
}: {
  programs.lsd = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/lsd/config.yaml".text = ''
    classic: false

    blocks:
      - permission
      - user
      - group
      - size
      - date
      - name

    color:
      when: auto
      theme: custom

    date: date

    dereference: false

    icons:
      when: auto
      theme: fancy
      separator: " "

    indicators: false

    layout: grid

    recursion:
      enabled: false

    size: default

    permission: rwx

    sorting:
      column: name
      reverse: false
      dir-grouping: none

    no-symlink: false

    total-size: true

    hyperlink: auto

    symlink-arrow: ⇒

    header: false

    literal: false

    truncate-owner:
      after:
      marker: ""
  '';

  home.file.".config/lsd/colors.yaml".text = with lib; let
    hexDigitToInt = c: let
      hexChars = "0123456789abcdef";
    in
      stringLength (head (splitString c (toLower hexChars)));

    hexToRgb = hexColor: let
      r = substring 0 2 hexColor;
      g = substring 2 2 hexColor;
      b = substring 4 2 hexColor;
      toDecimal = hex: hexDigitToInt (substring 0 1 hex) * 16 + hexDigitToInt (substring 1 1 hex);
    in "${toString (toDecimal r)};${toString (toDecimal g)};${toString (toDecimal b)}";
    mkColor = color: "38;2;${hexToRgb color}";
  in
    with config.lib.stylix.colors; ''
      color:
        user: ${mkColor base0D}
        group: ${mkColor base0E}

        permission:
          read: ${mkColor base0B}
          write: ${mkColor base0A}
          exec: ${mkColor base08}
          exec-sticky: ${mkColor base09}
          no-access: ${mkColor base03}

        date:
          hour-old: ${mkColor base05}
          day-old: ${mkColor base04}
          older: ${mkColor base03}

        size:
          none: ${mkColor base05}
          small: ${mkColor base0B}
          medium: ${mkColor base0A}
          large: ${mkColor base08}

        inode:
          valid: ${mkColor base0C}
          invalid: ${mkColor base08}

        links:
          valid: ${mkColor base0D}
          invalid: ${mkColor base08}

        tree-edge: ${mkColor base03}
    '';
}
