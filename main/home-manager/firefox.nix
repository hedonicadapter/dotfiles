{
  outputs,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    MOZ_LEGACY_PROFILES = 1;
  };
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-beta;
    profiles.hedonicadapter = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        vimium
        ublock-origin
        h264ify # pick codecs to block to mitigate youtube resource usage
        seventv
        betterttv
        adaptive-tab-bar-colour
        user-agent-string-switcher
      ];
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "unifiedExtensions.enabled" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "loop.enabled" = false;
        "browser.pocket.enabled" = false;
        "browser.search.suggest.enabled" = false;
        "plugin.state.flash" = 0;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-vpx.enabled" = false;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
        "findbar.modalHighlight" = true;
        "browser.urlbar.autocomplete.enabled" = false;
        "browser.search.context.loadInBackground" = true;
        "browser.tabs.loadBookmarksInBackground" = true;
        "layout.word_select.eat_space_to_next_word" = false;
        "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
        "browser.startup.homepage" = "about:blank";
        "gfx.webrender.all" = true;
      };
      search.engines = {
        "Nix Packages" = {
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@np"];
        };
      };
      search.force = true;

      extraConfig = builtins.readFile ./modules/firefox/user.js;
      userChrome = import ./modules/firefox/userChrome.css.nix {inherit outputs;};

      userContent = import ./modules/firefox/userContent.css.nix {inherit outputs;};
    };
  };
}
