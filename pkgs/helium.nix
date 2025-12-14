{
  appimageTools,
  lib,
  _sources,
}: let
  inherit (_sources.helium) pname version src;
in
  appimageTools.wrapType2 rec {
    inherit pname version src;

    extraInstallCommands = let
      contents = appimageTools.extract {inherit pname version src;};
    in ''
      install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram} --ozone-platform=wayland'

      cp -r ${contents}/usr/share/* $out/share/

      install -d $out/share/lib/${pname}
      cp -r ${contents}/opt/${pname}/locales $out/share/lib/${pname}/
    '';

    meta = {
      description = "Private, fast, and honest web browser (nightly builds)";
      homepage = "https://github.com/imputnet/${pname}";
      changelog = "https://github.com/imputnet/${pname}/releases/tag/${version}";
      license = lib.licenses.gpl3;
      maintainers = ["Ev357" "Prinky"];
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = pname;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
