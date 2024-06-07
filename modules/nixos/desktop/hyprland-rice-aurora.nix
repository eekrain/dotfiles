{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.desktop.hyprland;
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        # my-custom-font
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "CascadiaCode" ]; })
        twemoji-color-font
      ];

      fontconfig.defaultFonts = {
        # serif = [ "Noto Serif" ];
        serif = [ "DM Sans" ];
        sansSerif = [ "DM Sans" ];
        monospace = [ "DM Sans" ];
      };
    };

    environment.systemPackages = with pkgs; [
      python3
      # other pkgs
      eza
      fzf
      jq

      gnome.nautilus
      pcmanfm
    ];
  };
}
