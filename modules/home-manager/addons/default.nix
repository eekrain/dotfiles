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
      cava
      pavucontrol
      imv
      xarchiver
      wf-recorder
      # peazip
      # wavebox
    ];

    home.file."Pictures/wallpapers".source = ./wallpapers;
    home.file."Pictures/wallpapers".recursive = true;
  };
}
