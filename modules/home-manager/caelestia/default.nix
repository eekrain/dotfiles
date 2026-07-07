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

  # Home Manager Hyprland module configuration
  # Using null for packages to use the ones from NixOS module (per official docs)
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    # Export all environment variables to systemd user services
    # This fixes the common issue where programs work in terminal but not in systemd services
    systemd.variables = ["--all"];
    # HM manages only the master entrypoint (hyprland.lua). The leaf modules
    # (variables.lua, hyprland/*.lua, scheme/*.lua) live as plain editable files
    # in ~/.config/hypr/ so they can be tweaked without a rebuild.
    extraConfig = builtins.readFile ./hyprland.lua;
  };

  # xdg.configFile."hypr" = {
  #   source = ./hypr; # Assuming you have a directory named nvim in the same directory
  #   recursive = true; # This is important for directories
  # };

  # Integration with UWSM
  # xdg.configFile."uwsm/env" = {
  #   executable = true;
  #   text = ''
  #     # Caelestia specific environment variables
  #     export XDG_CURRENT_DESKTOP="Caelestia"
  #     export XDG_SESSION_DESKTOP="Caelestia"

  #     # Toolkit backend variables
  #     export GDK_BACKEND="wayland,x11,*"
  #     export QT_QPA_PLATFORM="wayland;xcb"
  #     export SDL_VIDEODRIVER="wayland"
  #     export CLUTTER_BACKEND="wayland"

  #     # Theming variables
  #     export GTK_THEME="Nordic"
  #     export XCURSOR_THEME="BreezeX-RoséPine"
  #     export XCURSOR_SIZE="24"

  #     # Qt platform theme
  #     export QT_QPA_PLATFORMTHEME="qt5ct"
  #     export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

  #     # NixOS specific
  #     export NIXOS_OZONE_WL="1"
  #     export ELECTRON_OZONE_PLATFORM_HINT="wayland"

  #     # XDG specifications
  #     export XDG_SESSION_TYPE="wayland"
  #     export XDG_CURRENT_DESKTOP="Hyprland"
  #     export XDG_SESSION_DESKTOP="Hyprland"

  #     # Others
  #     export EDITOR="code"
  #     export BROWSER="zen"
  #     export TERMINAL="kitty"
  #     export LIBSEAT_BACKEND="logind"
  #     export GDK_SCALE="1"
  #     export MOZ_ENABLE_WAYLAND="1"
  #     export _JAVA_AWT_WM_NONREPARENTING="1"

  #     # Additional Qt settings
  #     export QT_AUTO_SCREEN_SCALE_FACTOR="1"
  #     export QT_SCALE_FACTOR="1"
  #     export HYPRCURSOR_THEME="rose-pine-hyprcursor"
  #     export HYPRCURSOR_SIZE="24"

  #     export CAELESTIA_THEME="nordic";
  #     export CAELESTIA_ACCENT="blue";
  #   '';
  # };
}
