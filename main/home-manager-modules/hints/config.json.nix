# TODO: get dark/light mode and invert opencv backend accordingly
# TODO: get colors from color flake
{
  outputs,
  config,
  ...
}: let
  json = ''
    {
      "hints": {
        "hint_height": 30,
        "hint_width_padding": 10,
        "hint_font_size": 10,
        "hint_font_face": "${config.stylix.fonts.monospace.name}",
        "hint_font_r": 0,
        "hint_font_g": 0,
        "hint_font_b": 0,
        "hint_font_a": 1,
        "hint_pressed_font_r": 0.5,
        "hint_pressed_font_g": 0.5,
        "hint_pressed_font_b": 0.2,
        "hint_pressed_font_a": 1,
        "hint_upercase": true,
        "hint_background_r": 1,
        "hint_background_g": 1,
        "hint_background_b": 0.5,
        "hint_background_a": 0.6
      }
    }
  '';
in
  json
