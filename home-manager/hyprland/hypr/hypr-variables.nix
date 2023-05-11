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
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GBM_BACKEND = "nvidia-drm"; #on my laptop, wayland crashed using this env
      _JAVA_AWT_WM_NONREPARENTING = "1";
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      WLR_RENDERER = "vulkan";
      WLR_BACKEND = "vulkan";
      WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      # WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      GDK_SCALE = "2";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
