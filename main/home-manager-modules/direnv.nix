{inputs, ...}: {
  imports = [inputs.direnv-instant.homeModules.direnv-instant];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    direnv-instant.enable = true;
  };
}
