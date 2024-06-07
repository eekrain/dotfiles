{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  imports = [
    ./bat
    ./browser
    ./btop
    ./cava
    ./easyeffect-audio
    ./hypridle
    ./mimeapps
    ./mpv
    ./swaylock
    ./vscode
  ];

  options.myHmModules.programs = {
    bat = mkEnableOption "Enable bat settings";
    browser = mkEnableOption "Enable browser settings";
    btop = mkEnableOption "Enable btop settings";
    cava = mkEnableOption "Enable cava settings";
    easyeffect-audio = mkEnableOption "Enable easyeffect-audio settings";
    hypridle = mkEnableOption "Enable hypridle settings";
    mimeapps = mkEnableOption "Enable mimeapps settings";
    mpv = mkEnableOption "Enable mpv settings";
    swaylock = mkEnableOption "Enable swaylock settings";
    vscode = mkEnableOption "Enable vscode settings";
  };
}
