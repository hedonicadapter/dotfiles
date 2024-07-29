{pkgs, ...}: {
  home.packages = with pkgs; [
    ffmpegthumbnailer # for video thumbnails
    unar # for archive previews
    poppler # for pdf previews
  ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      show_hidden = true;
      sort_by = "modified";
      sort_sensitive = true;
      sort_dir_first = true;
      linemode = "mtime";
      scrolloff = 999;
      image_filter = "nearest";
    };
  };
}
