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
      nvtopPackages.nvidia
      vesktop
      amberol
      qview
      wf-recorder
      bruno # alternative to postman
      insomnia
      libreoffice
      ferdium
      remmina
      zoom-us

      nodejs_20
      bun
      ungoogled-chromium
      claude-code

      # winbox
      # responsivelyapp
      # redisinsight
      # hiddify
      # bitwarden-desktop
      # teams-for-linux
      # whatsapp-for-linux
      # distrobox
      # boxbuddy
    ];

    home.file."Pictures/wallpapers".source = ./wallpapers;
    home.file."Pictures/wallpapers".recursive = true;
  };
}
