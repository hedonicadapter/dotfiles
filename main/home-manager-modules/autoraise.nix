{pkgs}: {
  home.packages = with pkgs; [autoraise];
  home.file.".AutoRaise".text = ''
    pollMillis=20
    altTaskSwitcher=true
    requireMouseStop=false
    ignoreSpaceChanged=false
    disableKey="cmd"
    mouseDelta=0.1
  '';
}
