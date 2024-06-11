{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
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
      extraOptions = [ "-max-dedupe-search" "10" "-max-items" "500" ];
    };
  };
}
