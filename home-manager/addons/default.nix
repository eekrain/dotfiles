{ config, pkgs, ... }:
{
  imports = [
    ./browser.nix
    ./neovim
    ./ferdium
    ./easyeffect-audio.nix
  ];

  home.packages = with pkgs; [
    vscode
    discord
    winbox
    cava
    spotify
    spicetify-cli
    ferdium
    pavucontrol
    nixpkgs-fmt
    pamixer
    imv
    xarchiver
  ];
}
