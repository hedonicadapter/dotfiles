{pkgs, ...}: {
  home.packages = with pkgs; [
    ffmpegthumbnailer # for video thumbnails
    unar # for archive previews
    poppler # for pdf previews
    xdragon # drag and drop
  ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    keymap = {
      manager.keyap = [
        {
          exec = ''shell 'dragon -x -i -T "$1"' --confirm'';
          on = "<C-n>";
        }
        {
          on = "y";
          exec = [
            ''shell 'for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list' --confirm''
            "yank"
          ];
        }
        {
          on = "l";
          exec = "plugin augment-command --args='enter'";
          desc = "Enter the child directory, or open the file";
        }
        {
          on = "p";
          exec = "plugin augment-command --args'paste'";
          desc = "Paste into the hovered directory or CWD";
        }
      ];
    };
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "modified";
        sort_sensitive = true;
        sort_dir_first = true;
        linemode = "mtime";
        scrolloff = 255;
      };
      preview = {
        image_filter = "nearest";
      };
    };
    plugins = {
      augment-command = pkgs.fetchFromGitHub {
        owner = "hankertrix";
        repo = "augment-command.yazi";
        rev = "main";
        sha256 = "sha256-KAoGmgIE7Y6Roexq86j+ZFt9ebnQ/qfvQsSpFX/iyO4=";
      };
    };

    initLua = ''
      require("augment-command"):setup({
          prompt = false,
          default_item_group_for_prompt = "hovered",
          smart_enter = true,
          smart_paste = true,
          enter_archives = true,
          extract_behaviour = "rename",
          extract_retries = 3,
          must_have_hovered_item = true,
          skip_single_subdirectory_on_enter = true,
          skip_single_subdirectory_on_leave = true,
          ignore_hidden_items = false,
          wraparound_file_navigation = false,
      })
    '';
  };
}
