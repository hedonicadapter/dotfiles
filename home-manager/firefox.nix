{
  outputs,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-beta;
    profiles.hedonicadapter = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        vimium
        ublock-origin-lite
        seventv
        betterttv
        adaptive-tab-bar-colour
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
      userChrome =
        ''
          :root {
            ${outputs.cssColorVariables}
          }
        ''
        + builtins.readFile ./modules/firefox/userChrome.css;

      userContent = ''
        /* Hide Personalize new tab */
        @-moz-document url("about:home"),url("about:newtab"),url("about:blank") {
          .personalize-button {
            display: none !important;
          }
        }

        html {
          background: rgba(0,0,0,0) !important;
        }
        body {
          background: none !important;
        }
        * {
          border-radius:0.5rem;
        }

        /* new tab */
        .search-handoff-button {
          background: rgba(0,0,0,0.25) !important;
        }

        /* google */
        .sfbg {
          background: rgba(0,0,0,0) !important;
        }
        #appbar {
          background: rgba(0,0,0,0) !important;
        }
        .RNNXgb{
          background: rgba(0,0,0,0) !important;
        }

        /* youtube */
        #contentContainer, #guide-content, ytd-app, ytd-mini-guide-renderer, ytd-mini-guide-entry-renderer, ytd-masthead #background, .ytd-searchbox, ytd-watch-flexy, .ytd-watch-flexy  {
          background: rgba(0,0,0,0) !important;
        }
        #chips-wrapper.ytd-feed-filter-chip-bar-renderer, ytd-feed-filter-chip-bar-renderer[is-dark-theme] #right-arrow.ytd-feed-filter-chip-bar-renderer::before, #right-arrow.ytd-feed-filter-chip-bar-renderer::before {
          background: rgba(0,0,0,0) !important;
        }
        .ytd-searchbox, #search-icon-legacy.ytd-searchbox {
          border-color: transparent !important;
        }

        /* twitch */
        .top-nav__menu {
          background: rgba(0,0,0,0) !important;
        }
        .channel-root, .channel-root__info .channel-info-content {
          background: rgba(0,0,0,0) !important;
        }
        .user-menu-toggle > div, .eKDZrJ {
          background: transparent !important;
        }
        .side-nav, .side-nav-expanded {
          background: transparent !important;
        }
        nav > div {
          box-shadow:none !important;
        }
        input[type="search"] {
          background: transparent !important;
        }
        .stream-chat, .stream-chat-header, .chat-room, .Layout-sc-1xcs6mc-0 jWHzQH {
          background: transparent !important;
        }
        :root {
          --color-background-body: transparent !important;
        }

        /*reddit*/
        :root.theme-dark .sidebar-grid,
        :root.theme-dark .grid-container.grid,
        :root.theme-dark
          .sidebar-grid
          .theme-beta:not(.stickied):not(#left-sidebar-container):not(
            .left-sidebar-container
          ),
        :root.theme-dark
          .sidebar-grid
          .theme-rpl:not(.stickied):not(#left-sidebar-container):not(
            .left-sidebar-container
          ),
        :root.theme-dark
          .grid-container.grid
          .theme-beta:not(.stickied):not(#left-sidebar-container):not(
            .left-sidebar-container
          ),
        :root.theme-dark
          .grid-container.grid
          .theme-rpl:not(.stickied):not(#left-sidebar-container):not(
            .left-sidebar-container
          ) {
          background: rgba(0, 0, 0, 0) !important;
        }
        .bg-neutral-background {
          background: transparent !important;
        }
        .reddit-search-bar{
          background: transparent !important;
        }
        reddit-sidebar-nav {
          background: transparent !important;
        }
        shreddit-post {
          background: transparent !important;
        }
      '';
    };
  };
}
