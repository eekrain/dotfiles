{
  lib,
  stdenv,
  pkgs,
  makeWrapper,
  copyDesktopItems,
  wrapGAppsHook,
  ...
}: let
  version = "1.0.0-a.30";
  downloadUrl = {
    specific = {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-specific.tar.bz2";
      sha256 = "sha256:07y6h2xwqja9a9k0w9iqnd9hy06w6n320maaii7cqh6khx259cqm";
    };
    generic = {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-generic.tar.bz2";
      sha256 = "sha256:1nlaphylrrbsd2rmn1h5ml9wmxwshys04svpf5v8fv8ndihjyfj8";
    };
  };

  runtimeLibs = with pkgs;
    [
      libGL
      libGLU
      libevent
      libffi
      libjpeg
      libpng
      libstartup_notification
      libvpx
      libwebp
      nasm
      nspr
      nss_latest
      stdenv.cc.cc
      fontconfig
      libxkbcommon
      libdrm
      zlib
      freetype
      gtk3
      libxml2
      dbus
      dbus-glib
      xcb-util-cursor
      alsa-lib
      libpulseaudio
      pango
      atk
      cairo
      gdk-pixbuf
      glib
      udev
      libva
      mesa
      libnotify
      cups
      pciutils
      ffmpeg
      libglvnd
      pipewire
    ]
    ++ (with pkgs.xorg; [
      libxcb
      libX11
      libXcursor
      libXrandr
      libXi
      libXext
      libXcomposite
      libXdamage
      libXfixes
      libXScrnSaver
    ]);
in
  stdenv.mkDerivation {
    inherit version;
    pname = "zen-browser";

    src = builtins.fetchTarball {
      url = downloadUrl.specific.url;
      sha256 = downloadUrl.specific.sha256;
    };

    desktopSrc = ./.;

    phases = ["installPhase" "fixupPhase"];

    nativeBuildInputs = [makeWrapper copyDesktopItems wrapGAppsHook];

    installPhase = ''
      mkdir -p $out/bin && cp -r $src/* $out/bin
      install -D $desktopSrc/zen.desktop $out/share/applications/zen.desktop
      install -D $src/browser/chrome/icons/default/default128.png $out/share/icons/hicolor/128x128/apps/zen.png
    '';

    fixupPhase = ''
      chmod 755 $out/bin/*
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/zen
      wrapProgram $out/bin/zen --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}" \
        --set MOZ_LEGACY_PROFILES 1 --set MOZ_ALLOW_DOWNGRADE 1 --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/zen-bin
      wrapProgram $out/bin/zen-bin --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}" \
        --set MOZ_LEGACY_PROFILES 1 --set MOZ_ALLOW_DOWNGRADE 1 --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/glxtest
      wrapProgram $out/bin/glxtest --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/updater
      wrapProgram $out/bin/updater --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/vaapitest
      wrapProgram $out/bin/vaapitest --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}"
    '';

    meta.mainProgram = "zen";
  }
