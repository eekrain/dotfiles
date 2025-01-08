{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myHmModules.addons;
in {
  options.myHmModules.addons.enable = mkEnableOption "Enable addons settings";

  config = mkIf cfg.enable {
    programs.obs-studio.enable = true;

    home.packages = with pkgs; [
      vesktop
      winbox
      amberol
      qview
      wf-recorder
      responsivelyapp
      bruno # alternative to postman
      insomnia
      redisinsight
      hiddify
      bitwarden-desktop
      libreoffice
      teams-for-linux
      whatsapp-for-linux
    ];

    home.file."Pictures/wallpapers".source = ./wallpapers;
    home.file."Pictures/wallpapers".recursive = true;
  };
}
