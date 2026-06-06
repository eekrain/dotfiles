{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.myHmModules.addons;
in
{
  imports = [ ./ruby.nix ];

  options.myHmModules.addons.enable = mkEnableOption "Enable addons settings";

  config = mkIf cfg.enable {
    programs.obs-studio.enable = true;

    home.packages = with pkgs; [
      # nvtopPackages.nvidia
      vesktop
      amberol
      qview
      wf-recorder
      bruno # alternative to postman
      insomnia
      postman
      # pkgs2505.libreoffice
      ferdium
      remmina
      zoom-us

      bun

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.kilocode-cli
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.rtk
      # goose-cli

      inputs.antigravity-nix.packages.x86_64-linux.default

      obsidian
      psmisc
      pnpm
      filezilla
      tree
      # droid
      helium
      google-chrome
      drawio
      beekeeper-studio
      vlc
      inkscape
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
