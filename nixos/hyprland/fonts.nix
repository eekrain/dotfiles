{ config, pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      my-custom-font
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
}
