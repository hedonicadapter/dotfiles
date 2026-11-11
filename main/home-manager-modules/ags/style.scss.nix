{
  outputs,
  # home-manager-modules/compositor
  session,
  ...
}: let
  edge = outputs.palette.base0F;

  # CRT look: red/blue fringe either side plus a soft phosphor glow
  fringeRed = outputs.palette.base08;
  fringeBlue = outputs.palette.base0D;
  phosphor = outputs.palette.base05;
  textCrt = "-1px 0 rgba(${fringeRed}, 0.45), 1px 0 rgba(${fringeBlue}, 0.45), 0 0 6px rgba(${phosphor}, 0.35)";
  boxCrt = "-1px 0 0 rgba(${fringeRed}, 0.35), 1px 0 0 rgba(${fringeBlue}, 0.35), 0 0 6px rgba(${phosphor}, 0.2)";
  # Inside the frame; the edge glow appends its own shadows after these
  frameCrt = "inset 1px 0 0 rgba(${fringeRed}, 0.35), inset -1px 0 0 rgba(${fringeBlue}, 0.35), inset 0 0 10px rgba(${phosphor}, 0.15)";
  edgeFade = let
    a = session.animations.edgeFlash;
  in
    if a == null
    then "box-shadow 220ms ease-out"
    else "box-shadow ${toString a.ms}ms cubic-bezier(${builtins.concatStringsSep ", " (map builtins.toJSON a.curve)})";
  scss = ''
    * {
      background-color: transparent;
      border-radius: 1px;

      * .hover {
        border-color: ${outputs.palette.base07};
      }
    }

    .active {
      background-color: ${outputs.palette.base0D};
      color: ${outputs.palette.base07};
    }

    .muted {
      opacity: 0.6;
    }

    button, box {
      all:unset;
      padding: 0;
      background: transparent;
    }

    @keyframes spin {
        from { -gtk-icon-transform: rotate(0turn); }
        to { -gtk-icon-transform: rotate(1turn); }
    }

    @keyframes blink {
        0% {
          opacity: 1;
        }
        15% {
          opacity: 0.1;
        }
        52.5% {
          opacity: 1;
        }
        100% {
          opacity: 1;
        }
    }

    // Double-line HUD frame
    window.Outline {
      border: 3px double ${outputs.palette.base03};
      box-shadow: ${frameCrt};

      .ticks {
        color: rgba(${outputs.palette.base03}, 0.8);
      }
    }
    window.Outline.active-monitor {
      border: 3px double ${outputs.palette.base04};

      .ticks {
        color: ${outputs.palette.base04};
      }
    }

    // Phosphor glow and colour fringing on everything the bar draws
    window.Bar {
      label {
        text-shadow: ${textCrt};
      }
      icon {
        -gtk-icon-shadow: ${textCrt};
      }
      .bar-items .left,
      .bar-items .right {
        box-shadow: ${boxCrt};
      }
      .recording .main {
        color: ${outputs.palette.base08};
      }
    }

    // Edge glow: on instantly, fades out when the class drops. Frame shadows
    // come first in both lists so only the edge pair animates
    window.Outline {
      transition: ${edgeFade};
    }
    window.Outline.edge-left,
    window.Outline.edge-right,
    window.Outline.edge-top,
    window.Outline.edge-bottom {
      transition-duration: 0;
    }
    window.Outline.edge-left   { box-shadow: ${frameCrt}, inset 4px 0 0 0 ${edge}, inset 28px 0 28px -20px rgba(${edge}, 0.55); }
    window.Outline.edge-right  { box-shadow: ${frameCrt}, inset -4px 0 0 0 ${edge}, inset -28px 0 28px -20px rgba(${edge}, 0.55); }
    window.Outline.edge-top    { box-shadow: ${frameCrt}, inset 0 4px 0 0 ${edge}, inset 0 28px 28px -20px rgba(${edge}, 0.55); }
    window.Outline.edge-bottom { box-shadow: ${frameCrt}, inset 0 -4px 0 0 ${edge}, inset 0 -28px 28px -20px rgba(${edge}, 0.55); }

    window.Bar {
      color: ${outputs.palette.base05};
      font-size: 20px;

      .bar-items {
        margin-top: 1px;
        min-height: 26px;

        .bar-item {
          margin-left: 7px;
          margin-right: 7px;

          .main {
            padding-left: 7px;
            padding-right: 7px;
            padding-bottom: 2px;
          }
          .panel {}
        }

        > * {
          padding-left: 14px;
          padding-right: 14px;
          padding-top: 2px;
          margin-top: -1px;
        }

        .left {
          border: 0.5px solid ${outputs.palette.base03};
          .workspaces {
            .workspace-indicator {
              font-size: 20px;
            }
            .workspace {
              font-size: 20px;
              margin-right: 4px;
            }
            .focused-workspace {
              font-size: 21px;
              margin-left: 8px;

              .main {
              }
              .misc {
              }
            }

            .mode {
              margin-top: 1px;
              margin-left: -10px;

              // niri has no submaps — overview is the only modal state
              .NORMAL {
              }
              .OVERVIEW {
                background-color: ${outputs.palette.base0D};
                color: ${outputs.palette.base01};
              }
            }
          }

          .tray {
            margin-left: 4px;
            margin-right: 4px;
            margin-top: 1px;
            font-size: 17px;

            > * {
              padding: 0 3px;
            }
          }

          .media-player {
            margin-top: 2px;
            background-color: ${outputs.palette.base0E};
            color: ${outputs.palette.base00};

            .main {
              .media-controls {
                font-size: 17px;
                margin-left: 6px;
                margin-top:-1px;
              }

              .position-bar {
                border: 2px solid ${outputs.palette.base00};
                min-height: 8px;
                margin-top: 2px;
                margin-left: 3px;

                .current-position {
                  border: 1px solid ${outputs.palette.base0E};
                  background-color: ${outputs.palette.base00};
                  min-height: 6px;
                }
              }

              .position-and-length{
                padding: 0 6px;
                font-size: 17px;
                font-weight: 600;
              }
            }

            .panel {
              .cover-art {
                padding: 4px;
                margin-right: 4px;
              }
              .track-info {
                font-size: 17px;
                padding-bottom: 1px;
                padding-top: 2px;

                .album-title {}
                .artist-names {}
                .project-name {}
              }
            }
          }
        }

        .center {
          border: none;

          .title {
            label {
              min-height:24px;
            }
          }
        }

        .right {
          border: 0.5px solid ${outputs.palette.base03};
          .notifications {
            background-color: ${outputs.palette.base00};
            color: ${outputs.palette.base05};
            margin-right: 3px;
            margin-top: -2px;
            padding-bottom: 1px;

            :not(.latest) {
              min-height: 0;
            }
            .header {
              border: 2px solid transparent;
              font-size: 19px;

              .app-name {
                padding-left: 1px;
                padding-bottom: 1px;
                font-weight: 600;
              }
              .summary {
              }
              .time {
                font-size: 17px;
              }
              .close-button {
                margin-left: -4px;
                padding-right:1px;
              }
            }
            .body {
              padding-top: 4px;
            }
            .actions {
              padding-bottom: 4px;
              button {
              }
            }
          }

          .audio {
            .main { }

            .panel {
              padding: 1px;

              > * {
                padding-top: 1px;
                padding-bottom: 1px;
              }
            }

            .bar-label {
              font-size: 20px;
              padding-top: 1px;
            }

            .bar {
              font-size: 20px;
              margin-top: -3px;

              .low {
                color: ${outputs.palette.base05};
              }
              .mid {
                color: ${outputs.palette.base09};
              }
              .high {
                color: ${outputs.palette.base08};
              }

              .hovered {
                .low {
                  color: ${outputs.palette.base00};
                }
              }
            }
          }
          .audio.hovered {
            background-color: ${outputs.palette.base05};
            color: ${outputs.palette.base00};
          }

          .fan {
            margin-left: 1px;
            font-size: 16px;
          }

          // Same size so icons and labels share one baseline
          .bluetooth,
          .network,
          .keyboard-battery {
            font-size: 18px;
          }

          // Gap between icon and label
          .spaced-icon {
            margin-right: 5px;
          }

          .datetime {
            .day {
              margin-right: 6px;
              font-size: 17px;
            }
            .time {
              font-size: 20px;
            }
          }
        }
      }
    }
    window.Dash {
      .panel {
         border: 0.5px solid ${outputs.palette.base03};
      }
      .heading {
        padding: 1px;
        font-weight: bold;
      }

      .HAL {
         min-width: 380px;
         font-size: 22px;

        .responses {
          min-width: 380px;
          padding: 6px 8px;

          .response {
            margin-bottom: 6px;
          }

          .response.user {
            margin-right: 16px;

            .label {
              color: ${outputs.palette.base06};
            }
            .text {
              background-color: ${outputs.palette.base04};
              color: ${outputs.palette.base00};
            }
          }

          .response.puter {
            margin-left: 16px;
            margin-bottom: 10px;

            .label {
              color: ${outputs.palette.base07};
            }
            .text {
              background-color: ${outputs.palette.base05};
              color: ${outputs.palette.base00};
            }
          }
        }
        .textarea {
          margin-left: 4px;
          min-height: 200px;
        }
      }
      .audio-settings {
         min-width: 380px;

        .active {
          background-color: ${outputs.palette.base0D};
          color: ${outputs.palette.base07};
        }

        .device-panel {
          margin: 4px;
          min-width:380px;
        }
        .endpoints {
          margin: 4px;
        }
      }
    }

    window.Bar.active-monitor {
      .bar-items {
        .left {
            border-color: ${outputs.palette.base04};
        }
        .center {
        }
        .right {
            border-color: ${outputs.palette.base04};
        }
      }
    }

    menu {
      background-color: ${outputs.palette.base00};
      padding: 1px;
      margin: 0px;

      > * {
        padding: 0px;
        margin: 0px;
      }

      > *:hover {
          background-color: ${outputs.palette.base04};
          color: ${outputs.palette.base00};
      }
    }


    .low {
      color: ${outputs.palette.base05};

      .header {
        border-color: ${outputs.palette.base05};
        color: ${outputs.palette.base05};

        .app-name {
          background-color: ${outputs.palette.base05};
          color: ${outputs.palette.base00};
        }
      }

      .fan {
        animation: spin 2s steps(8) infinite;
      }
    }
    .mid {
      color: ${outputs.palette.base0A};

      .header {
        border-color: ${outputs.palette.base0C};
        color: ${outputs.palette.base05};

        .app-name {
            background-color: ${outputs.palette.base0C};
            color: ${outputs.palette.base00};
        }
      }

      .fan {
        animation: spin 1.5s steps(8) infinite;
      }
    }
    .high {
      color: ${outputs.palette.base08};

      .header {
        border-color: ${outputs.palette.base08};
        color: ${outputs.palette.base05};

        .app-name{
            background-color: ${outputs.palette.base08};
            color: ${outputs.palette.base05};
        }
      }

      .temperature-label {
        animation: blink 2.55s steps(14) infinite;
      }
      .fan {
        animation: spin 1s steps(8) infinite, blink 2.55s steps(14) infinite;
      }
    }

    .temperature {
      @each $name, $dur in (rpm-slow: 2s, rpm-mid: 1.5s, rpm-fast: 1s) {
        .fan.#{$name} {
          animation: spin $dur steps(8) infinite;
        }
        .high .fan.#{$name} {
          animation: spin $dur steps(8) infinite, blink 2.55s steps(14) infinite;
        }
      }
    }

  '';
in
  scss
