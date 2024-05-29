{ inputs, outputs, pkgs, lib, config, ... }:

let
  unstable = import <nixos-unstable> { };
  spotify-wrap = pkgs.writeShellScriptBin "wrap-spotify"
    (builtins.readFile ../../wrappers/spotify.nix);
  armcord-wrap = pkgs.writeShellScriptBin "wrap-armcord"
    (builtins.readFile ../../wrappers/armcord.nix);
  edge-wrap = pkgs.writeShellScriptBin "wrap-edge"
    (builtins.readFile ../../wrappers/edge.nix);
  obsidian-wrap = pkgs.writeShellScriptBin "wrap-obsidian"
    (builtins.readFile ../../wrappers/obsidian.nix);
  teams-wrap = pkgs.writeShellScriptBin "wrap-teams"
    (builtins.readFile ../../wrappers/teams.nix);
  vscode-wrap = pkgs.writeShellScriptBin "wrap-vscode"
    (builtins.readFile ../../wrappers/vscode.nix);
  beeper-wrap = pkgs.writeShellScriptBin "wrap-beeper"
    (builtins.readFile ../../wrappers/beeper.nix);
  steam-wrap = pkgs.writeShellScriptBin "wrap-steam"
    (builtins.readFile ../../wrappers/steam.nix);

  tofi-power-menu = pkgs.writeShellScriptBin "tofi-power-menu"
    (builtins.readFile ../../modules/tofi/power-menu.sh);

in {
  imports = [ inputs.ags.homeManagerModules.default ../../cachix.nix ];

  home.username = "hedonicadapter";
  home.homeDirectory = "/home/hedonicadapter";

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.nixneovimplugins.overlays.default
  ];

  fonts.fontconfig.enable = true;

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "beeper"
      "terraform"
      "steamcmd"
      "steam-original"
      "steam-run"
      "steam"
      "rider"
    ];

  home.packages = with pkgs; [

    google-cloud-sdk
    firebase-tools
    grim
    slurp
    lf
    jq
    cargo
    rustc
    azure-cli
    bicep
    gh
    nodePackages.pnpm
    libGLU

    nwg-look
    neovide
    jetbrains.rider
    transmission
    beeper
    #(callPackage ./neovide.nix { })
    (iosevka.override {
      privateBuildPlan =
        builtins.readFile ../../modules/Iosevka/build-plans.toml;
      set = "Term";
    })
    material-symbols
    font-awesome

    spotify-wrap
    armcord-wrap
    edge-wrap
    obsidian-wrap
    teams-wrap
    vscode-wrap
    beeper-wrap
    steam-wrap
    steamcmd
    # cachix
    bottles
    lutris

    tofi-power-menu

    bun
    nodePackages.prettier
    prettierd
    sassc
    typescript
    # nodePackages.typescript-language-server this runs with bunx
    # tailwindcss-language-server
    (with dotnetCorePackages; combinePackages [ sdk_6_0 sdk_7_0 sdk_8_0 ])
    csharp-ls
    azure-functions-core-tools
    csharpier
    sqlfluff
    go
    terraform
    stylua
    nixfmt
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "neovide";
    NIXOS_OZONE_WL = "1";
    # GTK_THEME = "Orchis-Yellow-Dark-Compact";
    ZSH_CUSTOM = "${config.home.homeDirectory}/.oh-my-zsh/custom";

    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    XDG_RUNTIME_DIR = "/run/user/$UID";
    # WINIT_X11_SCALE_FACTOR = 0.75;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.firefox = {
    enable = true;
    profiles.hedonicadapter = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      search.engines = {
        "Nix Packages" = {
          urls = [{
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
          }];

          icon =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };
      search.force = true;

      userContent = ''
        /* Hide Personalize new tab */
        @-moz-document url("about:home"),url("about:newtab"),url("about:blank") {
          .personalize-button {
            display: none !important;
          }
        }

        /* Highlight color inside browser content window */
        ::selection {
          background-color: dodgerblue !important;
          color: white !important;
        }
      '';
      userChrome = ''
         /* Firefox Beta v 0.0.1 */
         /* Source: https://github.com/BLACK4585/Firefox-Beta */
         /* based on: https://github.com/Tagggar/Firefox-Alpha/ */
         /* @import url("firefox-csshacks-master/chrome/autohide_bookmarks_and_main_toolbars.css"); */

         .unified-extensions-item {
           position: relative !important;
           top: 23px !important;
           left: 170px !important;
           z-index: 2 !important;
         }

         #fxa-toolbar-menu-button {
           position: relative !important;
           top: 23px !important;
           left: 170px !important;
           z-index: 2 !important;
         }

         #unified-extensions-button {
           position: relative !important;
           top: 23px !important;
           left: 170px !important;
           z-index: 2 !important;
         }

         #nav-bar:not([urlbar-exceeds-toolbar-bounds]) {
           overflow: visible !important;
         }


         :root {
           --6: 5px;
           --8: 8px;
           --tab-min-height: 24px !important;
           --tab-min-width: 24px !important;
           --toolbarbutton-border-radius: var(--6) !important;
           --tab-border-radius: var(--6) !important;
           --main: #77777770;
           --item: #77777730;
           --grey: #b8b8b8;
           --red: #ff000070;
           --toolbarbutton-hover-background: transparent !important;
           --toolbarbutton-active-background: transparent !important;
         }

         browser {
            border-radius: var(--tab-browser-radius) !important;
         }

         /* Clean UI */
         * {
           outline: none !important;
           box-shadow: none !important;
           border: none !important;
         }

         /* Highlight Selection color */
         ::selection {
           background-color: dodgerblue !important;
           color: white !important;
         }

         /* Customization Panel Fix */
         #customization-panelWrapper > .panel-arrowbox > .panel-arrow {
           margin-inline-end: initial !important;
         }

         /* Video Background Fix */
         video {
           background-color: black !important;
         }

         /* ❌ Hide Items ❌ */
         /* ❌ Tooltips ❌ */
         tooltip,

         /* ❌ Empty Space */
         spacer,.titlebar-spacer,

         /* ❌ Tab List */
         #alltabs-button,

         /* ❌ Extensions Menu
         #unified-extensions-button,

         /* ❌ #PanelUI-button */
         #PanelUI-menu-button,

         /* ❌ Titlebar Window Controls 
         .titlebar-buttonbox-container,

         /* ❌ Navigation Buttons */
         #back-button, #forward-button, #reload-button, #stop-reload-button,

         /* ❌ Menu Icons __ menuitem > .menu-iconic-left, */
          menu > .menu-iconic-left, .menu-right,

         /* ❌ Menu Separator */
         menuseparator, toolbarseparator,

         /* ❌ Menu Disabled */
         menuitem[disabled], menu[disabled],

         /* ❌ Overflow Icon */
         #nav-bar-overflow-button,

         /* ❌ url-bar Icons */
         #urlbar-zoom-button,#tracking-protection-icon-container,#identity-box,

         /* ❌ Bookmark Folder Icons */
         #PlacesToolbar .bookmark-item:not([label=""]) > .toolbarbutton-icon,

         /* ❌ Bookmarks [>] Button */
         #PlacesChevron,

         /* ❌ Tab Icon Overlay */
         .tab-icon-overlay,

         /* ❌ Tab Mute Icon */
         .tab-icon-sound-label,
         .tab-icon-overlay:not([muted]):is([soundplaying]),

         /* ❌ Tab Close Btn
         .tab-close-button:not([selected]),

         /* ❌ Tab Pinned Text */
         .tab-label-container[pinned],

         /* ❌ New Tab logo */
         .tabbrowser-tab[label="New Tab"] .tab-icon-image,

         /* ❌ Findbar Checkboxes */
         .findbar-container > checkbox,

         /* ❌ Menu Icons */
         #contentAreaContextMenu > menuitem > .menu-iconic-left,
         #context-navigation > menuitem > .menu-iconic-left,

         /* ❌ Downloads Icons */
         .downloadTypeIcon,
         #downloads-button > .toolbarbutton-badge-stack > .toolbarbutton-badge,
         :root:not([customizing]) #downloads-indicator-icon,
         #downloads-indicator-start-box, #downloads-indicator-start-image > *,
         #downloads-indicator-finish-box, #downloads-indicator-finish-image > *, 

         /* ❌ Private Indicator */
         .private-browsing-indicator {
           display: none !important;
           -moz-user-focus: none;
         }

         /* 🔗 Status Panel [Url Popup] */
         #statuspanel #statuspanel-label {
           font-weight: 600 !important;
           padding-inline: var(--6) !important;
           border-radius: var(--6) !important;
           margin: var(--8) !important;
           background-color: blue !important;
         }

         /* ℹ️ Findbar Ctrl+F */
         findbar {
           padding: 0 !important;
           margin: 0 8px !important;
           border-radius: var(--6) !important;
           width: 240px;
           background: var(--grey) !important;
           order: -1;
         }
         .findbar-container {
           padding: 0 !important;
           margin: 0 !important;
           height: var(--tab-min-height) !important;
         }
         .findbar-textbox {
           width: 168px !important;
           padding-inline: var(--6) !important;
           height: var(--tab-min-height) !important;
           color: black !important;
           background: none !important;
         }
         findbar toolbarbutton {
           width: 24px;
           padding: 4px !important;
           margin: 0 !important;
           background: none !important;
           fill: black !important;
           scale: 0.7;
         }

         /* *️⃣ Menu *️⃣ */
         /* *️⃣ Toolbar Menu Alt */
         #toolbar-menubar[autohide="true"][inactive="true"] {
           height: 0 !important;
           margin: 0 !important;
         }

         #toolbar-menubar {
           height: 24px !important;
           border-radius: var(--6);
           background-color: var(--grey);
           position: relative;
           margin: var(--6) var(--6) 0 var(--6);
           z-index: 3;
         }


         /* *️⃣ Toolbar Menu Item */
         menu[_moz-menuactive="true"]:not([disabled="true"]),
         menucaption[_moz-menuactive="true"]:not([disabled="true"]) {
           background-color: var(--main) !important;
           border-radius: 4px;
         }
         #main-menubar {
           margin: 4px;
           background-color: none;
           color: black;
           height: 16px !important;
         }

         /* *️⃣ Menu Popup Box */
         .menupopup-arrowscrollbox {
           border-radius: var(--8) !important;
           padding: var(--6) !important;
           background-color: var(--grey) !important;
           color: black !important;
         }

         /* Menu Position */
         menupopup {
           margin: var(--6) 0 !important;
         }

         #main-menubar menupopup {
             margin: var(--6) var(--8) 0 -8px !important;
         }

         menupopup > menuitem,
         menupopup > menu {
           appearance: none !important;
           max-height: 20px !important;
           min-height: 20px !important;
           border-radius: var(--6) !important;
           padding-inline: var(--6) !important;
           margin: 0 !important;



         }
         .menu-accel {
           margin-inline: var(--6) 0 !important;
         }

         /* ⬅️➡️🔄️ Context Nav Text Buttons*/
         menuitem[_moz-menuactive="true"]:not([disabled]),
         menupopup > menuitem[_moz-menuactive],
         menupopup > menu[_moz-menuactive] {
           background-color: var(--main) !important;
           color: black !important;  
         }
         #context-navigation {
           flex-direction: column !important;
         }
         #context-navigation > menuitem::before {
           content: attr(aria-label);
         }
         #context-navigation > menuitem {
           justify-content: start !important;
           border-radius: var(--6) !important;
           padding-inline: var(--6) !important;
           height: 20px !important;
           width: 100% !important;
         }

         /* ❎ Tabs Multi-row ❎ */
         scrollbox[part][orient="horizontal"] {
           display: flex;
           flex-wrap: wrap !important;
           height: none !important;
         }
        #tabbrowser-tabs{
         padding-top:2px !important;
        }
         #tabbrowser-tabs > * {
           padding-block: 2px !important;
           padding-inline:5px !important;
           margin-block: 2px !important;
           margin-inline:5px !important;
         }
         tab {
           margin: 0 4px 0 0 !important;
         }
         :root:not([customizing]) #titlebar {
           margin-bottom: -24px;
         }

         .tabbrowser-tab[fadein]:not([selected]):not([pinned]) {
           max-width: 120px !important;
           min-width: 80px !important;
         }
         .tabbrowser-tab .tab-background:not([selected]) {
           background: var(--item) !important;
         }
         .tab-label-container:not([selected]) {
           opacity: 0.5 !important;
         }
         .tab-content {
           padding-inline: 8px !important;
         }

         /* Tabs [Selected] */
         .tabbrowser-tab[selected][fadein]:not([pinned]) {
           max-width: 320px !important;
           min-width: 240px !important;
         }
         .tabbrowser-tab .tab-background[selected="true"] {
           background: var(--main) !important;
         }

         /* Tabs [Pinned] */
         .tabbrowser-tab[pinned] {
           width: calc(var(--tab-min-height) + var(--8)) !important;
         }

         /* Tabs Audio */
         #tabbrowser-tabs .tabbrowser-tab:is([soundplaying]) .tab-background {
           background-color: var(--red) !important;
           transition: background-color 0.1s ease !important;
         }

         /* Tabs Audio Favicon */
         .tab-icon-stack:not([pinned], [sharing], [crashed]):is([soundplaying], [muted])
           > :not(.tab-icon-overlay) {
           opacity: 1 !important;
         }

         /* Tab Close on hover */
         tab:not([pinned]):hover .tab-close-button {
           display: flex !important;
         }
         .tab-close-button {
           margin: -6px !important;
           opacity: 0.5;
           background-color: transparent !important;
         }

         /* New Tab by MMB on Tabs Toolbar  */
         /* #tabs-newtab-button, */
         /* #tabbrowser-arrowscrollbox-periphery { */
         /*   flex: 1; */
         /*   align-items: stretch !important; */
         /*   opacity: 0 !important; */
         /*   -moz-window-dragging: drag !important; */
         /* } */

         /* 🪟 Bookmarks Multi-row  */
         :root[BookmarksToolbarOverlapsBrowser] :where(#PersonalToolbar) {
           height: unset !important;
         }
         #PersonalToolbar {
           padding: 0 !important;
           margin: 0 !important;
           max-height: none !important;
         }
         #PlacesToolbarItems {
           display: flex;
           flex-wrap: wrap;
           padding: 0 var(--6);
         }
         #PlacesToolbarItems > .bookmark-item {
           margin: 0 var(--8) var(--8) 0 !important;
           padding: 0 var(--6) !important;
           background: var(--item) !important;
           color: grey !important;
           height: var(--tab-min-height);
         }



         /* 🔗 URLBAR Inbut https: */
         #urlbar-input {
           transition: transform 0.1s linear;
           transform: none !important;
           font-size: 1rem !important;
           color: lightgrey !important;
           padding-inline: 0px !important;
         }

         /* 📐 URLBAR in Tab */
         /* Source: https://github.com/MrOtherGuy/firefox-csshacks/.../selected_tab_as_urlbar.css */

         #main-window > body > box {
           position: relative;
           z-index: 1;
         }
         .urlbar-input-box {
           z-index: -1 !important;
         }
         #urlbar-input-container > :not(.urlbar-input-box) {
           opacity: 0;
         }
         #urlbar-background {
           background: none !important;
         }
         #urlbar-container {
           position: relative !important;
         }
         .urlbarView {
           background: var(--item);
           z-index: 1;
           padding: var(--6);
           border-radius: var(--6);
           left: 50vw;
           width: max(50vw, 320px) !important;
           transform: translateX(-50%) !important;
         }
         #nav-bar {
           height: var(--tab-min-height) !important;
           background-color: transparent !important;
         }

         /* 📐 Click Tab to Focus Urlbar */
         /* Source: https://github.com/MrOtherGuy/firefox-csshacks/.../click_selected_tab_to_focus_urlbar.css*/

         /* Make selected tab unclickable => click > capture box */
         .tabbrowser-tab:not([pinned])[selected] {
           pointer-events: none;
         }

         /* Restore pointer-events for usability */
         #TabsToolbar toolbarbutton,
         #TabsToolbar toolbaritem,
         .tabbrowser-tab,
         .tab-close-button,
         .tab-icon-stack {
           pointer-events: auto;
         }

         /* Capture box: click to focus urlbar */
         :root:not([customizing]) #urlbar-input-container::before {
           position: fixed;
           display: flex;
           flex: 1;
           height: var(--tab-min-height);
           width: 100%;
           top: var(--8);
           bottom: var(--8);
           content: "";
         }
         #urlbar-input-container:focus-within::before {
           display: none !important;
         }

         /* Tabs over the capture box */
         :root:not([customizing]) #TabsToolbar-customization-target {
           position: relative;
           z-index: 1;
           pointer-events: none;
         }

         /* Tab Focus => Url Select */
         #navigator-toolbox:focus-within
           .tabbrowser-tab:not([pinned])[selected]
           .tab-content {
           opacity: 0;
         }

         /* Tab URL */
         #navigator-toolbox:focus-within .tab-background:not([pinned])[selected] {
           background-position: var(--6) !important;
           background-color: var(--main) !important;
           background-size: auto !important;
           background-image: -moz-element(#urlbar-input) !important;
         }

         /* 🪟 Drag Window from urlbar */
         .urlbar-input-box,
         #urlbar-input,
         #urlbar-scheme,
         #urlbar-container
         #navigator-toolbox {
           -moz-window-dragging: drag;
           cursor: default;
         }

         /* ⬇️ Downloads Indicator */
         #downloads-button {
           position: fixed !important;
           top: 0 !important;
           right: 140px !important; 
           width: var(--tab-min-height);
           z-index: 1;
         }
         #downloads-indicator-progress-outer {
           position: fixed !important;
           align-items: end !important;
           top: var(--8) !important;
           right: 140px !important;
           left: auto !important;
           width: var(--6) !important;
           height: var(--tab-min-height) !important;
           border-radius: var(--6) !important;
           background: var(--item);
           visibility: visible !important;
           border: 1px solid white !important;
           margin-right: 8px;
         }
         #downloads-indicator-progress-inner {
           background: url("data:image/svg+xml;charset=UTF-8,%3csvg width='10' height='24' xmlns='http://www.w3.org/2000/svg'%3e%3crect width='10' height='24' fill='dodgerblue'/%3e%3c/svg%3e") bottom no-repeat !important;
           height: var(--download-progress-pcent) !important;
           border-radius: var(--6) !important;
         }
         #downloads-button[attention="success"] #downloads-indicator-progress-outer {
           background: lightgreen !important;
         }
         #downloads-button:is([attention="warning"], [attention="severe"])
           #downloads-indicator-progress-inner {
           background: red !important;
           height: var(--8) !important;
         }

         /* ⬇️ Downloads Panel */
         #downloadsPanel {
           position: fixed !important;
           margin: 4px var(--6) !important;
         }
         #downloadsPanel-mainView {
           background-color: #2b2a33 !important;
           color: white;
           padding: var(--6) !important;
         }
         #downloadsFooterButtons > button,
         #downloadsListBox > richlistitem {
           min-height: var(--tab-min-height) !important;
           padding: 0 0 0 var(--6) !important;
           margin: 0 !important;
           border-radius: var(--6) !important;
         }
         #downloadsListBox > richlistitem * {
           padding: 0 !important;
           margin: 0 !important;
           padding-block: 0 !important;
           border-radius: var(--6) !important;
         }
         #downloadsListBox > richlistitem > .downloadMainArea {
           margin-inline-end: var(--8) !important;
         }

         /* Search Suggestions Fix*/
         #urlbar-container #urlbar-input-container {
           opacity: 0;
         }
         .urlbarView {
           background-color: var(--lwt-accent-color); /* Pop-up background color (adaptive) */
           color: grey;                               /* Pop-up text color */
         }
      '';

    };
  };
  # programs.bash = {
  #   enable = true;
  #   historyControl = [ "erasedups" ];
  #  bashrcExtra = "eval \"$(zoxide init bash)\"";
  # };

  stylix.targets.tofi.enable = false;
  programs.tofi = {
    enable = true;
    settings = {
      width = "100%";
      height = "100%";
      border-width = 0;
      outline-width = 0;
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = 25;
      num-results = 5;
      font = "Work Sans";
      font-size = 24;
      background-color = "#000A";
      prompt-color = "#ECE1D7";
      selection-color = "#273142";
      selection-match-color = "#233524";

      history-file = "${config.home.homeDirectory}/.config/tofi/history";
    };
  };

  home.file.".config/obsidian/global.css".source =
    ../../modules/obsidian/global.css;

  home.file.".config/BetterDiscord" = {
    source = ../../modules/discord;
    recursive = true;
  };

  home.file.".oh-my-zsh/custom/themes" = {
    source = ../../modules/oh-my-zsh/themes;
    recursive = true;
  };

  programs.zsh = {
    enable = true;

    autosuggestion = { enable = true; };
    syntaxHighlighting = { enable = true; };
    historySubstringSearch = {
      enable = true;
      searchDownKey = "^n";
      searchUpKey = "^p";
    };

    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        eval "$(zoxide init zsh)"
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        setopt HIST_EXPIRE_DUPS_FIRST
        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_FIND_NO_DUPS
        setopt HIST_SAVE_NO_DUPS
      '';
      theme = "roundy/roundy";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  stylix.targets.foot.enable = false;
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        shell = "zsh";
        # font = "Iosevka Term:size=8";
        font = "JetBrainsMono Nerd Font:size=13";
        dpi-aware = "yes";
        pad = "40x0";
        font-size-adjustment = 0.9;
        line-height = 15;
      };
      colors = {
        foreground = "ECE1D7";
        background = "292522";
        selection-background = "403A36";
        selection-foreground = "ECE1D7";
        regular0 = "34302C";
        regular1 = "BD8183";
        regular2 = "78997A";
        regular3 = "E49B5D";
        regular4 = "7F91B2";
        regular5 = "B380B0";
        regular6 = "7B9695";
        regular7 = "C1A78E";
        bright0 = "867462";
        bright1 = "D47766";
        bright2 = "85B695";
        bright3 = "EBC06D";
        bright4 = "A3A9CE";
        bright5 = "CF9BC2";
        bright6 = "89B3B6";
        bright7 = "ECE1D7";
      };
      cursor = { blink = "yes"; };
    };
  };

  programs.git = {
    enable = true;
    userName = "hedonicadapter";
    userEmail = "mailservice.samherman@gmail.com";
    extraConfig = {
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.default;
    systemd.enable = true;
    systemd.variables = [ "--all" ];
    extraConfig = "${builtins.readFile ../../modules/hyprland/hyprland.conf}";
    # plugins = [
    # inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    # inputs.hyprlock.packages.${pkgs.system}.default
    # ];
  };
  home.file.".config/hypr/auto-start.sh".source =
    ../../modules/hyprland/auto-start.sh;
  home.file.".config/hypr/wallpaper-cycler.sh".source =
    ../../modules/hyprland/wallpaper-cycler.sh;

  home.file.".config/nvim/lua" = {
    source = ../../modules/nvim/lua;
    recursive = true;
  };
  home.file.".config/nvim/lua/reactive/presets" = {
    source = ../../modules/nvim/plugins/reactive;
    recursive = true;
  };

  programs.neovim = let
    toLua = str: ''
      lua << EOF
      ${str}
      EOF
    '';
    toLuaFile = file: ''
      lua << EOF
      ${builtins.readFile file}
      EOF
    '';
  in {
    package = pkgs.neovim-nightly;
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins;
      [
        {
          plugin = auto-session;
          config = toLua ''
            require('auto-session').setup({
              auto_session_suppress_dirs = { "~/", "~/Documents/coding", "~/Downloads", "/"},
              log_level = "error",
              auto_restore_enabled = false,
              auto_save_enabled = true,
              auto_session_root_dir = vim.fn.stdpath('data').."/sessions/",
            })
          '';
        }

        {
          plugin = coq_nvim;
          config = toLua ''
            vim.g.coq_settings = {
              display = {
                preview = {
                  border = "rounded",
                          
                },
              },
            }
          '';
        }

        {
          plugin = gitsigns-nvim;
          config = toLua ''
            require('gitsigns').setup()
          '';
        }

        {
          plugin = symbols-outline-nvim;
          config = toLua ''
            require("symbols-outline").setup()
          '';
        }

        {
          plugin = git-conflict-nvim;
          config = toLua ''
            require('git-conflict').setup()
          '';
        }

        {
          plugin = nvim-lspconfig;
          config = toLuaFile ../../modules/nvim/plugins/lsp.lua;
        }

        nvim-web-devicons
        telescope-fzf-native-nvim
        plenary-nvim
        nvim-ts-autotag
        vim-visual-multi
        vim-wakatime
        nvim-ts-context-commentstring
        sqlite-lua

        {
          plugin = nvim-spider;
          config = toLua ''
            require('spider').setup({
              skipInsignificantPunctuation = false,
            })
                        
            vim.keymap.set(
            	{ "n", "o", "x" },
            	"w",
            	"<cmd>lua require('spider').motion('w')<CR>",
            	{ desc = "Spider-w" }
            )
            vim.keymap.set(
            	{ "n", "o", "x" },
            	"e",
            	"<cmd>lua require('spider').motion('e')<CR>",
            	{ desc = "Spider-e" }
            )
            vim.keymap.set(
            	{ "n", "o", "x" },
            	"b",
            	"<cmd>lua require('spider').motion('b')<CR>",
            	{ desc = "Spider-b" }
            )
          '';
        }

        {
          plugin = nvim-treesitter-context;
          config = toLua ''
            require("treesitter-context").setup({
              enable = true,
              max_lines = 3,
            })

          '';
        }

        copilot-vim
        # {
        #   plugin = unstable.vimPlugins.CopilotChat-nvim;
        #   config = toLua ''
        #     require('CopilotChat').setup()
        #   '';
        # }

        neodev-nvim
        {
          plugin = nvim-cmp;
          config = toLuaFile ../../modules/nvim/plugins/cmp.lua;
        }
        cmp-nvim-lsp

        {
          plugin = dressing-nvim;
          config = toLua ''
            require('dressing').setup()
          '';
        }

        {
          plugin = conform-nvim;
          config = toLua ''
            require('conform').setup({
             formatters_by_ft = {
             lua = { "stylua" },
              javascript = { { "prettierd", "prettier" } },
              typescript = { { "prettierd", "prettier" } },
              javascriptreact = { { "prettierd", "prettier" } },
              typescriptreact = { { "prettierd", "prettier" } },
              json = { "prettierd" },
              html = { "prettierd" },
              css = { "prettierd" },
              scss = { "prettierd" },
              sass = { "prettierd" },
              astro = { "prettierd" },
              nix = { "nixfmt"},
              bicep = { "bicep" },
              cs = {"csharpier"},
              go = {"gofmt"},
             sql = {"sqlfluff"},
              tf = {"terraform_fmt"},

              },
            format_on_save = {
                -- These options will be passed to conform.format()
                timeout_ms = 1000,
                lsp_fallback = true,
              },

            })
          '';
        }

        {
          plugin = oil-nvim;
          config = toLua ''
            require('oil').setup()
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
          '';
        }

        {
          plugin = telescope-nvim;
          config = toLuaFile ../../modules/nvim/plugins/telescope.lua;
        }

        telescope-undo-nvim

        {
          plugin = nvim-neoclip-lua;
          config = toLua ''
            require('neoclip').setup()
          '';
        }

        {
          plugin = (nvim-treesitter.withPlugins (p: [
            p.tree-sitter-nix
            p.tree-sitter-vim
            p.tree-sitter-bash
            p.tree-sitter-lua
            p.tree-sitter-json
            p.tree-sitter-astro
            p.tree-sitter-bicep
            p.tree-sitter-c-sharp
            p.tree-sitter-dockerfile
            p.tree-sitter-go
            p.tree-sitter-html
            p.tree-sitter-javascript
            p.tree-sitter-jsdoc
            p.tree-sitter-scss
            p.tree-sitter-sql
            p.tree-sitter-typescript
            p.tree-sitter-tsx
            p.tree-sitter-terraform
          ]));
          config = toLuaFile ../../modules/nvim/plugins/treesitter.lua;
        }

        {
          plugin = zoxide-vim;
          config = toLua ''
            vim.cmd [[command! -bang -nargs=* -complete=customlist,zoxide#complete Z zoxide#vim_cd <args>]]
          '';
        }

        {
          plugin = nvim-colorizer-lua;
          config = toLuaFile ../../modules/nvim/plugins/colorizer.lua;
        }

        {
          plugin = guess-indent-nvim;
          config = toLua ''
            require('guess-indent').setup()

            vim.api.nvim_exec([[
              autocmd BufEnter * silent! :GuessIndent
            ]], false)
          '';
        }

        # {
        #   plugin = indent-blankline-nvim;
        #   config = toLua ''
        #     require("ibl").setup {}
        #   '';
        # }

        {
          plugin = comment-nvim;
          config = toLua "require('Comment').setup()";
        }

        {
          plugin = nvim-surround;
          config = toLua "require('nvim-surround').setup{}";
        }

        {
          plugin = eyeliner-nvim;
          config = toLua ''
            require('eyeliner').setup {
              highlight_on_key = true,
              dim = true
            }
          '';
        }

        {
          plugin = toggleterm-nvim;
          config = toLuaFile ../../modules/nvim/plugins/toggleterm.lua;
        }

        {
          plugin = nvim-cokeline;
          config = toLuaFile ../../modules/nvim/plugins/cokeline/cokeline.lua;
        }

        {
          plugin = unstable.vimPlugins.staline-nvim;
          config = toLuaFile ../../modules/nvim/plugins/staline.lua;
        }

        {
          plugin = mini-nvim;
          config = toLuaFile ../../modules/nvim/plugins/mini.lua;
        }

        {
          plugin = satellite-nvim;
          config = toLua ''
            require('satellite').setup()
          '';
        }

        {
          plugin = twilight-nvim;
          config = toLuaFile ../../modules/nvim/plugins/twilight.lua;
        }

        melange-nvim

        # {
        #   plugin = transparent-nvim;
        #   config = toLua ''
        #     require("transparent").setup()
        #   '';
        # }

        {
          plugin = pkgs.vimExtraPlugins.reactive-nvim;
          config = toLua ''
            require('reactive').setup {
              load = 'customCursor'
            }

          '';
        }

        {
          plugin = dropbar-nvim;
          config = toLua ''
            require('dropbar').setup() 
            vim.o.winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
          '';
        }
      ] ++ [ ];

    extraLuaConfig = ''
      ${builtins.readFile ../../modules/nvim/init.lua}
    '';
  };

  programs.ags = {
    enable = true;
    extraPackages = with pkgs; [ gtksourceview webkitgtk accountsservice ];
  };
  home.file.".config/ags" = {
    source = ../../modules/ags;
    recursive = true;
  };

  gtk.enable = true;

  gtk.iconTheme.package = pkgs.fluent-icon-theme;
  gtk.iconTheme.name = "Fluent";

  # gtk.font.name = "Noto Sans";
  # gtk.font.package = pkgs.noto-fonts;

  gtk.cursorTheme.package = pkgs.bibata-cursors-translucent;
  gtk.cursorTheme.name = "Bibata_Ghost";

  # gtk.theme.package = pkgs.orchis-theme;
  # gtk.theme.name = "Orchis-Yellow-Dark-Compact";

  xdg.mimeApps.defaultApplications = {
    "text/html" = "edge.desktop";
    "application/pdf" = "edge.desktop";
    "x-scheme-handler/http" = "edge.desktop";
    "x-scheme-handler/https" = "edge.desktop";
    "text/plain" = "neovide.desktop";
  };

  # xdg.configFile = {
  #   "gtk-4.0/assets".source =
  #     "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
  #   "gtk-4.0/gtk.css".source =
  #     "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
  #   "gtk-4.0/gtk-dark.css".source =
  #     "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  # };
}

