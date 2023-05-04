{ config, pkgs, ... }:
{
  fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    twemoji-color-font
  ];

  defaultFonts = {
    serif = [ "Noto Sans" ];
    sansSerif = [ "Noto Serif" ];
  };
}
