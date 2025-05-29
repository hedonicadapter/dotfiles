{pkgs}:
pkgs.stdenv.mkDerivation rec {
  pname = "oxygen-neon-cursors";
  version = "1.0"; # You can set this to the appropriate version

  src = pkgs.fetchFromGitHub {
    owner = "mesonjod";
    repo = "linux-oxygen-neon-cursors";
    rev = "master"; # You can specify a commit hash or tag for a specific version
    sha256 = "sha256-qU2cpbAMwAvWcZq8K5P6gK3WFMB5H4wAeYqDxYRVvJs="; # Replace with the actual hash
  };

  installPhase = ''
    echo "Output path: $out/share/icons/Oxygen-Neon"
    mkdir -p $out/share/icons/Oxygen-Neon
    cp -r * $out/share/icons/Oxygen-Neon
  '';

  meta = with pkgs.lib; {
    description = "Oxygen Neon Cursor Theme";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [hedonicadapter];
  };
}
