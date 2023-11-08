{ config, pkgs, lib, ... }:
{
  home = {
    sessionVariables = {
      EDITOR = "code";
      BROWSER = "brave";
      TERMINAL = "kitty";

      LIBSEAT_BACKEND = "logind";

      # WLR_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";

      GDK_SCALE = "1";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";


      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.libsForQt5.qt5.qtbase}/lib/qt-${pkgs.libsForQt5.qt5.qtbase.version}/plugins";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
