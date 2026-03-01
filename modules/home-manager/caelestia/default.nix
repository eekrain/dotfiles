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
    # Export all environment variables to systemd user services
    # This fixes the common issue where programs work in terminal but not in systemd services
    systemd.variables = ["--all"];
    # Caelestia manages its own hyprland.conf, so we use extraConfig as a placeholder
    # to prevent the HM warning about empty settings
    extraConfig = ''
      $hypr = ~/.config/hypr
      $hl = $hypr/hyprland
      $cConf = ~/.config/caelestia

      # Variables (colours + other vars)
      exec = cp -L --no-preserve=mode --update=none $hypr/scheme/default.conf $hypr/scheme/current.conf
      source = $hypr/scheme/current.conf
      source = $hypr/variables.conf

      # User variables
      exec = mkdir -p $cConf && touch -a $cConf/hypr-vars.conf
      source = $cConf/hypr-vars.conf

      # Configs
      source = $hl/env.conf
      source = $hl/general.conf
      source = $hl/input.conf
      source = $hl/misc.conf
      source = $hl/animations.conf
      source = $hl/decoration.conf
      source = $hl/group.conf
      source = $hl/execs.conf
      source = $hl/rules.conf
      source = $hl/gestures.conf
      source = $hl/keybinds.conf

      # User configs
      exec = mkdir -p $cConf && touch -a $cConf/hypr-user.conf
      source = $cConf/hypr-user.conf
    '';
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
