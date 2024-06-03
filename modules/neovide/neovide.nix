{ rustPlatform, fetchFromGitHub, pkg-config, freetype, fontconfig, xorg, ... }:

rustPlatform.buildRustPackage rec {
  pname = "neovide";
  version = "unstable-2021-05-22";

  src = fetchFromGitHub {
    owner = "neovide";
    repo = pname;
    rev = "deb4dd5"; # This is the latest commit at the time of writing, replace it with the commit you want to build
    sha256 = "sha256:0kakrxqqzqa09nxx5zk0iapnkj48k2v8hdjlxm8s5x1hzy3y5smi"; # This needs to be replaced with the correct hash
  };

  cargoSha256 = "sha256:1qmfijg6l4f4d17l49hr6g6yj94l8zq0klk4cjqmkh9k56jv6b6l"; # This needs to be replaced with the correct hash

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ freetype fontconfig xorg.libX11 xorg.libXext ];

  meta = with lib; {
    description = "No Nonsense Neovim Client in Rust";
    homepage = "https://github.com/neovide/neovide";
    license = licenses.mit;
    maintainers = with maintainers; [ ]; # Add your name here
  };
}