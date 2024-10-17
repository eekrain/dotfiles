{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.desktop.hyprland;
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
  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    # Install the default .config for configuration reference
    home.file.".config.example" = {
      source = "${pkgs.my-illogical-impulse-dots}/.config";
      recursive = true; # link recursively
      executable = true; # make all files executable
    };

    home.packages = [pkgs.wl-clip-persist pkgs.cliphist];
    wayland.windowManager.hyprland = {
      # plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
      #   hyprbars
      #   hyprexpo
      # ];

      # FIXME please copy all files inside dotfiles/modules/home-manager/desktop/hyprland-rice-illogical-impulse/config
      # except this default.nix into your ~/.config
      # because there is a config in which it cant be managed by home-manager
      extraConfig = ''
        # This config sources other files in `hyprland` and `custom` folders
        # You wanna add your stuff in file in `custom`

        exec-once = ags &

        # This is my way of starting swww
        # Feel free to just change it to only swww-daemon or modify the myWallpaperInit script
        exec-once = ${myWallpaperInit}/bin/myWallpaperInit

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
  };
}
