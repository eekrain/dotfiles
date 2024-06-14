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
  initMyWallpaper = pkgs.writeShellScriptBin "initMyWallpaper" ''
    swww clear
    sleep 1
    swww img ~/Pictures/wallpapers/1.jpg --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
    sleep 5
    # then sets my favorite .gif wallpaper
    swww img ~/Pictures/wallpapers/misono-mika-angel-blue-archive-moewalls.gif --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
  '';
in {
  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    home.packages = [initMyWallpaper]; #install custom script
    # Install the default .config for configuration reference
    home.file.".config.example" = {
      source = "${pkgs.my-illogical-impulse-dots}/.config";
      recursive = true; # link recursively
      executable = true; # make all files executable
    };
    wayland.windowManager.hyprland = {
      plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
        # hyprbars
        hyprexpo
      ];

      # FIXME please copy all files inside dotfiles/modules/home-manager/desktop/hyprland-rice-illogical-impulse/config
      # except this default.nix into your ~/.config
      # because there is a config in which it cant be managed by home-manager
      extraConfig = ''
        # This config sources other files in `hyprland` and `custom` folders
        # You wanna add your stuff in file in `custom`
        exec-once = swww-daemon
        exec-once = initMyWallpaper

        # Defaults
        source=~/.config/hypr/hyprland/env.conf
        source=~/.config/hypr/hyprland/execs.conf
        source=~/.config/hypr/hyprland/general.conf
        source=~/.config/hypr/hyprland/rules.conf
        source=~/.config/hypr/hyprland/colors.conf
        source=~/.config/hypr/hyprland/keybinds.conf
      '';
    };

    services.cliphist = {
      enable = true;
      allowImages = true;
      extraOptions = ["-max-dedupe-search" "10" "-max-items" "500"];
    };
  };
}
