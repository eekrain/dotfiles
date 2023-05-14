{ config, pkgs, ... }:
{
  imports = [
    ./browser.nix
    ./neovim
    ./ferdium
    ./easyeffect-audio.nix
  ];
  programs = {
    obs-studio.enable = true;
  };

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
    wf-recorder
  ];
}
