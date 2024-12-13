{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.mkShellNoCC {
  # services.k3s.enable = true;

  packages = with pkgs;
    [
      vscode
      azure-cli
      bicep
      terraform
      ansible
      azure-functions-core-tools
    ]
    # Language servers
    ++ [
      nodePackages.bash-language-server
      terraform-ls
      terraform-lsp
      dockerfile-language-server-nodejs
      ansible-language-server
    ]
    # Linters
    ++ [
      ansible-lint
    ];
}
