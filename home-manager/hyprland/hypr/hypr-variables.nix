{ config, pkgs, lib, ... }:
{
  home = {
    sessionVariables = {
      EDITOR = "code";
      BROWSER = "brave";
      TERMINAL = "kitty";

      MOZ_ENABLE_WAYLAND = "1";
      LIBSEAT_BACKEND = "logind";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.libsForQt5.qt5.qtbase}/lib/qt-${pkgs.libsForQt5.qt5.qtbase.version}/plugins";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";

      # LIBVA_DRIVER_NAME = "nvidia";
      # WLR_RENDERER = "vulkan";
      # GBM_BACKEND = "nvidia-drm"; #on my laptop, wayland crashed using this env
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      # WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      WLR_RENDERER_ALLOW_SOFTWARE = "1";

      GDK_SCALE = "1";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
