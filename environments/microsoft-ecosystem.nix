with import <nixpkgs> { };

mkShell {
  name = "dotnet-env";
  packages = [
    (with dotnetCorePackages; combinePackages [ sdk_6_0 sdk_7_0 sdk_8_0 ])
    powershell
    zoxide
    fzf
  ];

  shellHook = ''
    if [ -n "$PS1" ]; then
      eval "$(zoxide init bash)"
    fi
    export PATH="$PWD/node_modules/.bin/:$PATH"
  '';
}
