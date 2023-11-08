{ config, pkgs, lib, osConfig, ... }:
{
  home = {
    sessionVariables = lib.mkMerge [
      {
        EDITOR = "code";
        BROWSER = "brave";
        TERMINAL = "kitty";

        LIBSEAT_BACKEND = "logind";

        GDK_SCALE = "1";
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XCURSOR_SIZE = "32";

        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_SCALE_FACTOR = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.libsForQt5.qt5.qtbase}/lib/qt-${pkgs.libsForQt5.qt5.qtbase.version}/plugins";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      }
      (lib.mkIf (osConfig.hardware.amdgpu.enable) {
        LIBVA_DRIVER_NAME = "radeonsi";
        VDPAU_DRIVER = "radeonsi";
      })
      (lib.mkIf (osConfig.hardware.nvidia.enable) {
        GBM_BACKEND = "nvidia-drm"; #on my laptop, wayland crashed using this env
        GBM_BACKENDS_PATH = "/etc/gbm";
        LIBVA_DRIVER_NAME = "nvidia"; # hardware acceleration
        WLR_RENDERER = "vulkan";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __GL_VRR_ALLOWED = "0";
        WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      })
    ];
  };
}
