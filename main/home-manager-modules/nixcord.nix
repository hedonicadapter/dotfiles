{
  outputs,
  pkgs,
  lib,
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
    quickCss = ''
      * {
          font-family: 'Mx437 DOS/V re. JPN30'!important;
      }

      body {
          --border-thickness: 1px;
      }
      :root {
          --text-0: ${outputs.palette.base07};
          --text-1: ${outputs.palette.base07};
          --text-2: ${outputs.palette.base06};
          --text-3: ${outputs.palette.base06};
          --text-4: ${outputs.palette.base04};
          --text-5: ${outputs.palette.base03};
          --bg-1: ${outputs.palette.base03};
          --bg-2: ${outputs.palette.base00};
          --bg-3: ${outputs.palette.base00};
          --bg-4: ${outputs.palette.base00};
          --hover: ${outputs.palette.base01};
          --active: ${outputs.palette.base02};
          --active-2: ${outputs.palette.base03};
          --message-hover: var(--hover);
          --accent-1: ${outputs.palette.base0A};
          --accent-2: ${outputs.palette.base0F};
          --accent-3: ${outputs.palette.base0B};
          --accent-4: ${outputs.palette.base0D};
          --accent-5: ${outputs.palette.base09};
          --accent-new: ${outputs.palette.base08};
          --mention: linear-gradient(to right,
      color-mix(in hsl, var(--accent-2), transparent 90%) 40%, transparent);
          --mention-hover: linear-gradient(to right,
      color-mix(in hsl, var(--accent-2), transparent 95%) 40%, transparent);
          --reply: linear-gradient(to right,
      color-mix(in hsl, var(--text-3), transparent 90%) 40%, transparent);
          --reply-hover: linear-gradient(to right,
      color-mix(in hsl, var(--text-3), transparent 95%) 40%, transparent);
          --online: ${outputs.palette.base0B};
          --dnd: ${outputs.palette.base08};
          --idle: ${outputs.palette.base0A};
          --streaming: ${outputs.palette.base0D};
          --offline: var(--text-4);
          --border-light: var(--hover);
          --border: ${outputs.palette.base03};
          --border-hover: var(--accent-2);
          --button-border: ${outputs.palette.base06};
          --border-thickness: 1px !important;

          --red-1: ${outputs.palette.base08};
          --red-2: ${outputs.palette.base08};
          --red-3: ${outputs.palette.base08};
          --red-4: ${outputs.palette.base08};
          --red-5: ${outputs.palette.base08};
          --green-1: ${outputs.palette.base0B};
          --green-2: ${outputs.palette.base0B};
          --green-3: ${outputs.palette.base0B};
          --green-4: ${outputs.palette.base0B};
          --green-5: ${outputs.palette.base0B};
          --blue-1: ${outputs.palette.base0D};
          --blue-2: ${outputs.palette.base0D};
          --blue-3: ${outputs.palette.base0D};
          --blue-4: ${outputs.palette.base0D};
          --blue-5: ${outputs.palette.base0D};
          --yellow-1: ${outputs.palette.base0A};
          --yellow-2: ${outputs.palette.base0A};
          --yellow-3: ${outputs.palette.base0A};
          --yellow-4: ${outputs.palette.base0A};
          --yellow-5: ${outputs.palette.base0A};
          --purple-1: ${outputs.palette.base0E};
          --purple-2: ${outputs.palette.base0E};
          --purple-3: ${outputs.palette.base0E};
          --purple-4: ${outputs.palette.base0E};
          --purple-5: ${outputs.palette.base0E};
      }
    '';
  };
}
