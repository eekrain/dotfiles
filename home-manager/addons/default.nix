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
    cava
    spotify
    spicetify-cli
    # ferdium
    pavucontrol
    nixpkgs-fmt
    pamixer
  ];
}
