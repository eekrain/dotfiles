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
      target = "hyprland-session.target";
    };
  };

  # Integration with UWSM
  home.file.".config/uwsm/env-caelestia" = {
    executable = true;
    text = ''
      #!/bin/sh
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
    '';
  };
}