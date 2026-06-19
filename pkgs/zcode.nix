{
  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
  runCommand,
}: let
  pname = "zcode";
  version = "3.1.2";

  src = fetchurl {
    url = "https://cdn.zcode-ai.com/zcode/electron/releases/${version}/ZCode-${version}-linux-x64.AppImage";
    # hash = lib.fakeHash;
    hash = "sha256-IJ9Px7nRWuMWXlu2vmNJMG3/8fvzfHi78+ObbLWCBL0=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  # The wrapped AppImage. `bin/zcode` is the buildFHSEnv/bwrap launcher that
  # mounts the bundled libraries into an FHS sandbox.
  app = appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/zcode.desktop $out/share/applications/zcode.desktop
      substituteInPlace $out/share/applications/zcode.desktop --replace-fail 'Exec=AppRun' 'Exec=${pname}'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    meta = {
      description = "ZCode Desktop App";
      homepage = "https://zcode-ai.com";
      license = lib.licenses.unfree;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  };
in
  # ZCode bundles its own libraries in the FHS sandbox. The AppImage's AppRun
  # shim prepends $APPDIR/usr/lib to LD_LIBRARY_PATH. If the desktop session
  # already leaks a LD_LIBRARY_PATH into the process (NixOS' pipewire JACK
  # module exports one), the bundled libs (libglib etc.) can no longer be
  # resolved and the app dies silently on launch — it looks "stuck". Clearing
  # LD_LIBRARY_PATH before entering the sandbox fixes the desktop launch.
  runCommand "${pname}-${version}" {
    nativeBuildInputs = [makeWrapper];
    inherit (app) meta;
  } ''
    mkdir -p $out
    for p in $(ls -A ${app}); do
      [ "$p" = "bin" ] && continue
      cp -rs ${app}/$p $out/
    done
    mkdir -p $out/bin
    makeWrapper ${app}/bin/zcode $out/bin/zcode \
      --run 'unset LD_LIBRARY_PATH'
  ''
