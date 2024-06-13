{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.desktop.nautilus;
  nautEnv = pkgs.buildEnv {
    name = "nautilus-env";

    paths = with pkgs; [
      gnome.nautilus
      gnome.nautilus-python
    ];
  };
in {
  options.myModules.desktop.nautilus.enable = mkEnableOption "Enable nautilus installation";

  config = mkIf cfg.enable {
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty";
    };

    environment = {
      systemPackages = [nautEnv];
      pathsToLink = [
        "/share/nautilus-python/extensions"
      ];
      sessionVariables = {
        NAUTILUS_4_EXTENSION_DIR = lib.mkDefault "${nautEnv}/lib/nautilus/extensions-4";
        GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
          gst-plugins-good
          gst-plugins-bad
          gst-plugins-ugly
          gst-libav
        ]);
      };
    };
  };
}
