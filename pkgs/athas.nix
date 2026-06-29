{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbcommon,
  libgbm,
  nspr,
  nss,
  pango,
  systemd,
  xz,
  zlib,
}: let
  pname = "athas";
  version = "0.8.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/athasdev/athas/releases/download/v${version}/Athas_${version}_linux-x86_64.tar.gz";
      sha256 = "sha256-7VA1mKGfW1qq1Pe3UQxbsZFGdvR8bRNpqbfQraVVFps=";
    };

    sourceRoot = ".";

    nativeBuildInputs = [
      autoPatchelfHook
      wrapGAppsHook3
    ];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
      libxcb
      libxkbcommon
      libgbm
      nspr
      nss
      pango
      systemd
      xz
      zlib
    ];

    appendRunpaths = [
      "${placeholder "out"}/lib/athas/libexec"
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/athas
      cp -r athas.app/* $out/lib/athas/

      mkdir -p $out/bin
      ln -s $out/lib/athas/bin/athas $out/bin/athas

      install -Dm444 $out/lib/athas/share/applications/com.code.athas.desktop \
        $out/share/applications/com.code.athas.desktop

      mkdir -p $out/share/icons/hicolor
      cp -r $out/lib/athas/share/icons/hicolor/. $out/share/icons/hicolor/

      runHook postInstall
    '';

    meta = {
      description = "Lightweight cross-platform code editor built with Tauri and a bundled CEF webview";
      homepage = "https://github.com/athasdev/athas";
      license = lib.licenses.agpl3Only;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
