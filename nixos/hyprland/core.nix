{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # hyprland spesificsystemPackages = with pkgs; [
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    wev
    #other pkgs
    exa
    fzf
    python39
    jq
  ];
}
