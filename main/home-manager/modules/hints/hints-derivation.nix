{
  lib,
  python3,
  fetchFromGitHub,
  gobject-introspection,
  wrapGAppsHook3,
  at-spi2-core,
  ydotool,
}:
python3.pkgs.buildPythonApplication {
  pname = "hints";
  version = "latest";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hedonicadapter";
    repo = "hints";
    rev = "main";
    hash = "sha256-0Ee3BzwWNEyW0WpF+ZKWCdzKcQ58O3HYdnomTMn8pUU=";
  };

  disabled = python3.pkgs.pythonOlder "3.10";

  build-system = with python3.pkgs; [setuptools];

  dependencies = with python3.pkgs; [
    pygobject3
    pillow
    pyscreenshot
    opencv-python
    pyatspi

    pkgs.ydotool
    pkgs.gtk-layer-shell
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    at-spi2-core
  ];

  makeWrapperArgs = ["\${gappsWrapperArgs[@]}"];

  meta = {
    description = "Navigate GUIs without a mouse by typing hints in combination with modifier keys";
    homepage = "https://github.com/AlfredoSequeida/hints";
    license = with lib.licenses; [gpl3Only];
    platforms = lib.platforms.linux;
    maintainers = [];
  };
}
