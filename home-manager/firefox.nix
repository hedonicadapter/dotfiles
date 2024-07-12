{
  outputs,
  pkgs,
  ...
}: let
  colorNames = builtins.attrNames outputs.colors;
  cssColorVariables = builtins.concatStringsSep "\n" (
    builtins.map (color: "--color-${color}: ${outputs.colors.${color}};") colorNames
  );
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-beta;
    profiles.hedonicadapter = {
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
            ${cssColorVariables}
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
          background: none !important;
        }
        body {
          background: rgba(0,0,0,0.25) !important;
        }
      '';
    };
  };
}