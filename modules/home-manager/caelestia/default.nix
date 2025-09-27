{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.caelestia.homeManagerModules.default
    ./configuration.nix
    ./packages.nix
    ./theme.nix
  ];

  # Enable Caelestia
  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "xdg-desktop-portal-hyprland.service";
    };
  };

  # Integration with UWSM
  home.file.".config/uwsm/env" = {
    executable = true;
    text = ''
      # Caelestia specific environment variables
      export XDG_CURRENT_DESKTOP="Caelestia"
      export XDG_SESSION_DESKTOP="Caelestia"

      # Toolkit backend variables
      export GDK_BACKEND="wayland,x11,*"
      export QT_QPA_PLATFORM="wayland;xcb"
      export SDL_VIDEODRIVER="wayland"
      export CLUTTER_BACKEND="wayland"

      # Theming variables
      export GTK_THEME="Nordic"
      export XCURSOR_THEME="Bibata-Modern-Classic"
      export XCURSOR_SIZE="24"

      # Qt platform theme
      export QT_QPA_PLATFORMTHEME="qt5ct"
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

      # NixOS specific
      export NIXOS_OZONE_WL="1"
      export ELECTRON_OZONE_PLATFORM_HINT="auto"

      # XDG specifications
      export XDG_SESSION_TYPE="wayland"
      export XDG_CURRENT_DESKTOP="Hyprland"
      export XDG_SESSION_DESKTOP="Hyprland"

      # Others
      export EDITOR="code"
      export BROWSER="zen"
      export TERMINAL="kitty"
      export LIBSEAT_BACKEND="logind"
      export GDK_SCALE="1"
      export MOZ_ENABLE_WAYLAND="1"
      export _JAVA_AWT_WM_NONREPARENTING="1"

      # Additional Qt settings
      export QT_AUTO_SCREEN_SCALE_FACTOR="1"
      export QT_SCALE_FACTOR="1"
    '';
  };
}
