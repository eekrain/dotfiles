{ config, pkgs, ... }:
{
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      my-custom-font
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "CascadiaCode" ]; })
      twemoji-color-font
    ];

    fontconfig.defaultFonts = {
      serif = [ "Noto Sans" ];
      sansSerif = [ "Noto Serif" ];
    };
  };
}
