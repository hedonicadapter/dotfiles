{
  userName,
  userEmail,
  pkgs,
}: {
  programs.git = {
    enable = true;
    userName = userName;
    userEmail = userEmail;
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "${
        pkgs.git.override {withLibsecret = true;}
      }/bin/git-credential-libsecret";

      color.ui = "auto";

      delta = {
        navigate = true;
      };
      merge = {
        conflictstyle = "zdiff3";
      };

      push = {
        autoSetupRemote = true;
      };
    };
    delta .enable = true;
  };
}
