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
  myWallpaperInit = pkgs.writeShellScriptBin "myWallpaperInit" ''
    # Init swww-daemon via hyprctl dispatch
    hyprctl dispatch -- exec swww-daemon --format xrgb
    # Clear it first from previous wallpaper
    swww clear
    sleep 1
    # Sets light wallpaper first so it's not just pitch black
    swww img ~/Pictures/wallpapers/roshidere-orange.png --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
    sleep 5
    # then sets my favorite .gif wallpaper, im delaying it cus it's loading slow
    # swww img ~/Pictures/wallpapers/misono-mika-angel-blue-archive-moewalls.gif
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
    wl-clip-persist
    cliphist
    hypridle
    hyprlock
  ];

  # Hyprland settings managed by home manager
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = ["--all"];
    };
    xwayland.enable = true;

    extraConfig = ''
      # This config sources other files in `~/.config/hypr/hyprland` folders

      exec-once = ags &

      # This is my way of starting swww
      # Feel free to just change it to only swww-daemon or modify the myWallpaperInit script
      # exec-once = ${myWallpaperInit}/bin/myWallpaperInit

      # Clipboard stuff
      exec-once = ${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both
      exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist -max-dedupe-search 10 -max-items 500 store
      exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist -max-dedupe-search 10 -max-items 500 store

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
