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

      inputs.bunnix.packages.${pkgs.stdenv.hostPlatform.system}.default

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
      # goose-cli

      inputs.antigravity-nix.packages.x86_64-linux.default

      obsidian
      psmisc
      (pnpm.override { nodejs-slim = nodejs; })
      filezilla
      tree
      # droid
      helium
      zcode
      athas
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

    # ZCode self-registers ~/.local/share/applications/zcode.desktop on every
    # launch, but points Exec at the raw extracted binary, which only works
    # inside the FHS sandbox — so the desktop entry dies instantly (looks
    # "stuck"). Pin the correct .desktop at XDG_DATA_HOME as a symlink to the
    # package's read-only store copy: the app's clobber attempt hits EACCES on
    # the store target and is caught/handled, leaving this working entry in
    # place. See pkgs/zcode.nix for the matching LD_LIBRARY_PATH wrapper.
    home.file.".local/share/applications/zcode.desktop".source =
      "${pkgs.zcode}/share/applications/zcode.desktop";
  };
}
