{ config, pkgs, lib, ... }:
let
  inherit (lib) fileContents;
in
{
  environment.systemPackages = with pkgs; [
    # hyprland spesificsystemPackages = with pkgs; [
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    wev
    wlr-randr
    #other pkgs
    exa
    fzf
    python39
    jq
  ];

  environment.shellInit = ''
    export STARSHIP_CONFIG=${
      pkgs.writeText "starship.toml"
      (fileContents ./starship.toml)
    }
  '';
}
