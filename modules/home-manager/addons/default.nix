{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.myHmModules.addons;
in
{
  options.myHmModules.addons.enable = mkEnableOption "Enable addons settings";

  config = mkIf cfg.enable {
    programs.obs-studio.enable = true;

    home.packages = with pkgs; [
      discord
      winbox
      cava
      pavucontrol
      nixpkgs-fmt
      pamixer
      imv
      xarchiver
      wf-recorder
      lollypop
      # peazip
      gscreenshot
      motrix
      # wavebox
      vscode
    ];

    xdg.configFile."hypr/wallpapers".source = ./wallpapers;
    xdg.configFile."hypr/wallpapers".recursive = true;
  };
}
