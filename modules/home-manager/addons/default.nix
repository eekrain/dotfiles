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
      ferdium
      remmina
      zoom-us

      inputs.bunnix.packages.${pkgs.stdenv.hostPlatform.system}.default

      # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-desktop
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.zcode
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codegraph
      # goose-cli

      inputs.antigravity-nix.packages.x86_64-linux.default

      obsidian
      psmisc
      (pnpm.override { nodejs-slim = nodejs; })
      filezilla
      tree
      # droid
      helium
      athas
      google-chrome
      drawio
      # beekeeper-studio # insecure: EOL Electron 39, re-enable when upstream updates
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
