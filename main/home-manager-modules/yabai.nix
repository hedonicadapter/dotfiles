{
  home.file.".config/karabiner/assets/complex_modifications/yabai.json".text = ''
    {
      "title": "yabai window manager bindings",
      "rules": [
        {
          "description": "yabai navigation",
          "manipulators": [

            {
              "type": "basic",
              "from": { "key_code": "h", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m window --focus west" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "j", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m window --focus south" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "k", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m window --focus north" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "l", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m window --focus east" }]
            },

            {
              "type": "basic",
              "from": { "key_code": "h", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --warp west" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "j", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --warp south" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "k", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --warp north" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "l", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --warp east" }]
            },

            {
              "type": "basic",
              "from": { "key_code": "h", "modifiers": { "mandatory": ["option","control"] }},
              "to": [{ "shell_command": "yabai -m window --resize left:-30:0" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "j", "modifiers": { "mandatory": ["option","control"] }},
              "to": [{ "shell_command": "yabai -m window --resize bottom:0:30" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "k", "modifiers": { "mandatory": ["option","control"] }},
              "to": [{ "shell_command": "yabai -m window --resize top:0:-30" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "l", "modifiers": { "mandatory": ["option","control"] }},
              "to": [{ "shell_command": "yabai -m window --resize right:30:0" }]
            },

            {
              "type": "basic",
              "from": { "key_code": "m", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m window --toggle zoom-fullscreen" }]
            },

            {
              "type": "basic",
              "from": { "key_code": "f", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --toggle float" }]
            },

            {
              "type": "basic",
              "from": { "key_code": "w", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m window --close" }]
            },

            {
              "type": "basic",
              "from": { "key_code": "1", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m space --focus 1" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "2", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m space --focus 2" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "3", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m space --focus 3" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "4", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m space --focus 4" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "5", "modifiers": { "mandatory": ["option"] }},
              "to": [{ "shell_command": "yabai -m space --focus 5" }]
            },

            {
              "type": "basic",
              "from": { "key_code": "1", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --space 1; yabai -m space --focus 1" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "2", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --space 2; yabai -m space --focus 2" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "3", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --space 3; yabai -m space --focus 3" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "4", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --space 4; yabai -m space --focus 4" }]
            },
            {
              "type": "basic",
              "from": { "key_code": "5", "modifiers": { "mandatory": ["option","shift"] }},
              "to": [{ "shell_command": "yabai -m window --space 5; yabai -m space --focus 5" }]
            }

          ]
        }
      ]
    }
  '';
}
