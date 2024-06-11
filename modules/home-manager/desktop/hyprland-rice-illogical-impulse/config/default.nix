{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    xdg.configFile."hypr/hyprland".source = ./hyprland;
    xdg.configFile."hypr/hyprland".recursive = true;

    wayland.windowManager.hyprland = {
      plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
        # hyprbars
        hyprexpo
      ];

      extraConfig = ''
        # This config sources other files in `hyprland` and `custom` folders
        # You wanna add your stuff in file in `custom`

        # Defaults
        source=~/.config/hypr/hyprland/env.conf
        source=~/.config/hypr/hyprland/execs.conf
        source=~/.config/hypr/hyprland/general.conf
        source=~/.config/hypr/hyprland/rules.conf
        source=~/.config/hypr/hyprland/keybinds.conf
      '';
    };

    services.cliphist = {
      enable = true;
      allowImages = true;
      extraOptions = [ "-max-dedupe-search" "10" "-max-items" "500" ];
    };
  };
}
