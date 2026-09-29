# Official notarized release artifact. bsdtar (not unzip) preserves the
# Developer ID signature — unzip strips it and macOS then refuses the bundle.
{
  lib,
  fetchurl,
  libarchive,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omniwm";
  version = "0.7.2";

  src = fetchurl {
    url = "https://github.com/OmniNull/OmniWM/releases/download/v${finalAttrs.version}/OmniWM-v${finalAttrs.version}.zip";
    hash = "sha256-wVPdL16U4JC4WG2E1AR5qv2AA44JOSNfMMS4Zyk3+8E=";
  };

  dontUnpack = true;
  strictDeps = true;

  nativeBuildInputs = [libarchive];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    bsdtar -xf $src -C $out/Applications/

    mkdir -p $out/bin
    ln -s $out/Applications/OmniWM.app/Contents/MacOS/OmniWM $out/bin/OmniWM
    ln -s $out/Applications/OmniWM.app/Contents/MacOS/omniwmctl $out/bin/omniwmctl

    runHook postInstall
  '';

  meta = {
    description = "macOS tiling window manager inspired by niri and Hyprland";
    homepage = "https://github.com/OmniNull/OmniWM";
    license = lib.licenses.gpl2Only;
    mainProgram = "OmniWM";
    platforms = lib.platforms.darwin;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
