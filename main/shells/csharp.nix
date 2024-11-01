{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.mkShellNoCC {
  # services.k3s.enable = true;

  packages = with pkgs;
    [
      mono # for sniprun c#
      (with dotnetCorePackages; combinePackages [sdk_6_0 sdk_7_0 sdk_8_0])
      jetbrains.rider
      vscode
    ]
    # Language servers
    ++ [
      dockerfile-language-server-nodejs
      sqls
    ]
    # Formatters
    ++ [
      csharpier
      sqlfluff
    ];
}
