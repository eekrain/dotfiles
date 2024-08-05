{
  appimageTools,
  fetchurl,
  lib,
}: let
  pname = "responsivelyapp";
  version = "1.13.0";

  src = fetchurl {
    url = "https://github.com/responsively-org/responsively-app-releases/releases/download/v${version}/ResponsivelyApp-${version}.AppImage";
    # sha256 = lib.fakeHash;
    sha256 = "sha256-fwaAQwbdhLR37QZG0MRvYMyt0LP5/VZ8qnxgKvmRvRA=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      substituteInPlace $out/responsivelyapp.desktop --replace 'Exec=AppRun' 'Exec=${pname} --ozone-platform-hint=auto --gtk-version=4 --ignore-gpu-blocklist --enable-features=Vulkan,VaapiVideoDecoder,VaapiVideoEncoder'
    '';
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/responsivelyapp.desktop $out/share/applications/responsivelyapp.desktop
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/16x16/apps/responsivelyapp.png \
        $out/share/icons/hicolor/16x16/apps/responsivelyapp.png
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/32x32/apps/responsivelyapp.png \
        $out/share/icons/hicolor/32x32/apps/responsivelyapp.png
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/48x48/apps/responsivelyapp.png \
        $out/share/icons/hicolor/48x48/apps/responsivelyapp.png
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/64x64/apps/responsivelyapp.png \
        $out/share/icons/hicolor/64x64/apps/responsivelyapp.png
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/128x128/apps/responsivelyapp.png \
        $out/share/icons/hicolor/128x128/apps/responsivelyapp.png
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/256x256/apps/responsivelyapp.png \
        $out/share/icons/hicolor/256x256/apps/responsivelyapp.png
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/responsivelyapp.png \
        $out/share/icons/hicolor/512x512/apps/responsivelyapp.png
    '';
  }
