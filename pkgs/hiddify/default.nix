{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "hiddify";
  version = "2.5.7";

  src = fetchurl {
    url = "https://github.com/hiddify/hiddify-next/releases/download/v${version}/Hiddify-Linux-x64.AppImage";
    # hash = lib.fakeHash;
    hash = "sha256-5RqZ6eyurRtoOVTBLZqoC+ANi4vMODjlBWf3V4GXtMg=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopSrc = ./.;
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: [pkgs.libepoxy];

    extraInstallCommands = ''
      install -m 444 -D ${desktopSrc}/hiddify.desktop $out/share/applications/hiddify.desktop
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
  }
