{ config, pkgs, ... }:
{
  imports = [
    ./browser.nix
    ./neovim
  ];

  home.packages = with pkgs; [
    vscode
    discord
    winbox
    mpv
    cava
    spotify
    spicetify-cli
    chromium
    ferdium
  ];
}
