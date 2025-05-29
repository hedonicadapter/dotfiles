{outputs, ...}: let
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

    window.Outline {
      border: 0.5px solid ${outputs.palette.base03};
    }
    window.Outline.active-monitor {
      border: 0.5px solid ${outputs.palette.base04};
    }

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

              .NORMAL {
              }
              .RUN {
                background-color: ${outputs.palette.base0D};
                color: ${outputs.palette.base01};
              }
              .BROWSER {
                background-color: ${outputs.palette.base0D};
                color: ${outputs.palette.base01};
              }
              .FILES {
                background-color: ${outputs.palette.base06};
                color: ${outputs.palette.base02};
              }
              .QUERY {
                background-color: ${outputs.palette.base0C};
                color: ${outputs.palette.base01};
              }
              .UTIL {
                background-color: ${outputs.palette.base0E};
                color: ${outputs.palette.base01};
              }
              .SYSTEM {
                background-color: ${outputs.palette.base0F};
                color: ${outputs.palette.base01};
              }
              .POWER {
                background-color: ${outputs.palette.base08};
                color: ${outputs.palette.base05};
              }
              .DISPLAY {
                background-color: ${outputs.palette.base0D};
                color: ${outputs.palette.base06};
              }
              .AUDIO {
                background-color: ${outputs.palette.base0E};
                color: ${outputs.palette.base06};
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

          .bluetooth {
            font-size: 18px;
          }

          .network {
            font-size: 18px;
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

  '';
in
  scss
