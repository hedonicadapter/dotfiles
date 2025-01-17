{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.mkShellNoCC {
  # services.k3s.enable = true;

  packages = with pkgs;
    [
      vscode

      azure-cli
      azure-cli-extensions.azure-devops
      azure-functions-core-tools
      bicep

      terraform
      ansible

      google-cloud-sdk
      firebase-tools
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
