{
  lib,
  python3,
  fetchFromGitHub,
  gobject-introspection,
  wrapGAppsHook3,
  at-spi2-core,
}:
python3.pkgs.buildPythonApplication {
  pname = "hints";
  version = "latest";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AlfredoSequeida";
    repo = "hints";
    rev = "main";
    sha256 = "sha256-NnSxVTzVl1/ZWPkuCqZoZc/u+c+nBUpz7ZwtavqT/rg=";
  };

  disabled = python3.pkgs.pythonOlder "3.10";

  build-system = with python3.pkgs; [setuptools];

  dependencies = with python3.pkgs; [
    pygobject3
    pillow
    pyscreenshot
    opencv-python
    pyatspi

    pkgs.gtk-layer-shell
    evdev
    dbus-python
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    at-spi2-core
  ];

  makeWrapperArgs = ["\${gappsWrapperArgs[@]}"];

  env = {
    HINTS_EXPECTED_BIN_DIR = "$out/bin";
    HOME = "$out/home/";
  };

  meta = {
    description = "Navigate GUIs without a mouse by typing hints in combination with modifier keys";
    homepage = "https://github.com/AlfredoSequeida/hints";
    license = with lib.licenses; [gpl3Only];
    platforms = lib.platforms.linux;
    maintainers = [];
  };
}
