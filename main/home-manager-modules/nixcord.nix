{
  outputs,
  pkgs,
}: {
  programs.nixcord = {
    enable = true;
    vesktop.enable = true;

    # programs.nixcord.userPlugins
    #     # enable custom user plugins from github
    #     # type: attrsOf (coercedTo (strMatching regex))

    config = {
      useQuickCss = true;
      themeLinks = [
        "https://refact0r.github.io/system24/theme/system24.theme.css"
      ];
      frameless = true;
      disableMinSize = true;

      plugins = {
        alwaysAnimate.enable = true;
        alwaysTrust.enable = true;
        betterSettings = {
          enable = true;
          eagerLoad = false;
        };
        betterGifPicker.enable = true;
        betterUploadButton.enable = true;
        clearURLs.enable = true;
        consoleJanitor.enable = true;
        copyFileContents.enable = true;
        experiments.enable = true;
        fakeNitro.enable = true;
        favoriteEmojiFirst.enable = true;
        favoriteGifSearch.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        forceOwnerCrown.enable = true;
        friendsSince.enable = true;
        messageLogger.enable = true;
        moreKaomoji.enable = true;
        noOnboardingDelay.enable = true;
        noRPC.enable = true;
        relationshipNotifier.enable = true;
        reverseImageSearch.enable = true;
        reviewDB.enable = true;
        secretRingToneEnabler.enable = true;
        showHiddenThings.enable = true;
        showMeYourName.enable = true;
        silentTyping.enable = true;
        silentMessageToggle.enable = true;
        spotifyShareCommands.enable = true;
        streamerModeOnStream.enable = true;
        unindent.enable = true;
        voiceChatDoubleClick.enable = true;
        vcNarrator .enable = true;
        volumeBooster.enable = true;
        whoReacted.enable = true;
        youtubeAdblock.enable = true;
        webScreenShareFixes.enable = true;
        imageZoom = {
          enable = true;
          saveZoomValues = false;
        };
      };
    };
    quickCss =
      ''
        :root {
          --txt-pad: 5px;
          --bg-0: ${outputs.palette.base00}; /* main background color */
          --bg-1: ${outputs.palette.base01}; /* background color for secondary elements */
          --bg-2: ${outputs.palette.base02}; /* color of neutral buttons */
          --bg-3: ${outputs.palette.base03}; /* color of neutral buttons when hovered */

          --hover: hsla(0, 0%, 40%, 0.1); /* keeping original as it's an opacity value */
          --active: hsla(0, 0%, 40%, 0.2); /* keeping original as it's an opacity value */
          --selected: var(--active);

          --txt-dark: ${outputs.palette.base00};
          --txt-link: ${outputs.palette.base0C};
          --txt-0: ${outputs.palette.base07};
          --txt-1: ${outputs.palette.base05};
          --txt-2: ${outputs.palette.base04};
          --txt-3: ${outputs.palette.base03};

          --acc-0: ${outputs.palette.base0A};
          --acc-1: color-mix(in oklch, ${outputs.palette.base0A}, white 10%);
          --acc-2: color-mix(in oklch, ${outputs.palette.base0A}, black 10%);

          --border-width: 1px;
          --border-color: ${outputs.palette.base03};
          --border-hover-color: ${outputs.palette.base0A};
          --border-transition: 0.2s ease;

          --online-dot: ${outputs.palette.base0B};
          --dnd-dot: ${outputs.palette.base08};
          --idle-dot: ${outputs.palette.base0A};
          --streaming-dot: ${outputs.palette.base0E};

          --mention-txt: ${outputs.palette.base0C};
          --mention-bg: color-mix(in oklch, ${outputs.palette.base0C}, transparent 90%);
          --mention-overlay: color-mix(in oklch, ${outputs.palette.base0C}, transparent 90%);
          --mention-hover-overlay: color-mix(in oklch, ${outputs.palette.base0C}, transparent 95%);
          --reply-overlay: var(--active);
          --reply-hover-overlay: var(--hover);

          --pink: ${outputs.palette.base08};
          --pink-1: color-mix(in oklch, ${outputs.palette.base08}, black 10%);
          --pink-2: color-mix(in oklch, ${outputs.palette.base08}, black 20%);
          --purple: ${outputs.palette.base0E};
          --purple-1: color-mix(in oklch, ${outputs.palette.base0E}, black 10%);
          --purple-2: color-mix(in oklch, ${outputs.palette.base0E}, black 20%);
          --cyan: ${outputs.palette.base0C};
          --yellow: ${outputs.palette.base0A};
          --green: ${outputs.palette.base0B};
          --green-1: color-mix(in oklch, ${outputs.palette.base0B}, black 10%);
          --green-2: color-mix(in oklch, ${outputs.palette.base0B}, black 20%);
        }

        * {
            font-family: 'Mx437 DOS/V re. JPN30'!important;
        }
      ''
      + import ../home-manager-modules/discord/custom.css.nix {inherit outputs;};
  };
}
