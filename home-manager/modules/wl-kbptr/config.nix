{outputs, ...}: let
  configContent = ''
    [general]
    home_row_keys=

    [mode_tile]
    label_color=${outputs.colors_opaque.white}
    label_select_color=${outputs.colors_opaque.beige}
    unselectable_bg_color=${outputs.transparentize outputs.colors_opaque.grey 0.4}
    selectable_bg_color=${outputs.transparentize outputs.colors_opaque.green 0.6}
    selectable_border_color=${outputs.transparentize outputs.colors_opaque.green 0.0}

    [mode_bisect]
    label_color=${outputs.colors_opaque.white}
    label_font_size=20
    label_padding=12
    pointer_size=20
    pointer_color=${outputs.colors_opaque.black}

    unselectable_bg_color=${outputs.transparentize outputs.colors_opaque.grey 0.4}
    even_area_bg_color=${outputs.transparentize outputs.colors_opaque.green 0.6}
    even_area_border_color=${outputs.transparentize outputs.colors_opaque.green 0.0}
    odd_area_bg_color=${outputs.transparentize outputs.colors_opaque.cyan 0.6}
    odd_area_border_color=${outputs.transparentize outputs.colors_opaque.cyan 0.0}
    history_border_color=#3339
  '';
in
  configContent
