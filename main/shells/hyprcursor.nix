{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    hyprcursor
    xcur2png
  ];

  shellHook = ''
    WORK_DIR="/tmp/cursor-workspace"

    if [ ! -d "$WORK_DIR" ]; then
      mkdir -p "$WORK_DIR"
      echo "Creating new workspace at $WORK_DIR"
      hyprcursor-util --extract "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ" --output "$WORK_DIR"
    else
      echo "Using existing workspace at $WORK_DIR"
    fi

    cd "$WORK_DIR"
    git init
    nvim .
  '';
}
