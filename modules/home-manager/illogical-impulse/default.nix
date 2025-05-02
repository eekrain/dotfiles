{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # I dont know why gif wallpaper when it's cached it's just stuck from booting
  # So i will do it manually
  # TODO : If you dont want to use a .gif wallpaper, delete the script below
  # TODO : Then scroll to bottom
  myWallpaperInit = pkgs.writeShellScriptBin "myWallpaperInit" ''
    # Init swww-daemon via hyprctl dispatch
    hyprctl dispatch -- exec swww-daemon --format xrgb
    # Clear it first from previous wallpaper
    swww clear
    sleep 1
    # Sets light wallpaper first so it's not just pitch black
    swww img ~/Pictures/wallpapers/misono-mika-angel-blue-archive-moewalls.jpg --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
    sleep 3
    # then sets my favorite .gif wallpaper, im delaying it cus it's loading slow
    swww img ~/Pictures/wallpapers/misono-mika-angel-blue-archive-moewalls.gif
  '';
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./programs
    ./dots.nix
    ./theme.nix
  ];

  # Dependency for illogical-impulse ags bar/shell
  home.packages = with pkgs; [
    clipse
    wl-clip-persist
    hypridle
    hyprlock
    grimblast
    satty
  ];

  # Hyprland settings managed by home manager
  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    # Disbale for withUWSM
    systemd.enable = false;

    extraConfig = ''
      # This config sources other files in `~/.config/hypr/hyprland` folders

      exec-once = ags &

      # TODO : If you want to use my wallpaper script, use this config
      exec-once = ${myWallpaperInit}/bin/myWallpaperInit
      # TODO : If you are just using static wallpaper, use this instead
      # exec-once = swww-daemon --format xrgb

      # Clipboard stuff
      exec-once = ${pkgs.clipse}/bin/clipse -listen
      exec-once = ${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular

      # Defaults
      source=~/.config/hypr/hyprland/env.conf
      source=~/.config/hypr/hyprland/execs.conf
      source=~/.config/hypr/hyprland/general.conf
      source=~/.config/hypr/hyprland/rules.conf
      source=~/.config/hypr/hyprland/colors.conf
      source=~/.config/hypr/hyprland/keybinds.conf
    '';
  };
}
