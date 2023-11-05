{ config, pkgs, lib, ... }:
{
  imports = [
    ./browser.nix
    ./neovim
    ./ferdium
    ./easyeffect-audio
  ];
  programs = {
    obs-studio.enable = true;
  };

  home.packages = with pkgs; [
    # vscode #install manually via nix-env
    discord
    winbox
    cava
    spotify
    spicetify-cli
    ferdium
    pavucontrol
    nixpkgs-fmt
    pamixer
    imv
    xarchiver
    wf-recorder
    gnome.file-roller
    lollypop
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.zipAttrsWith
      (_: values: values)
      (
        let
          subtypes = type: program: subt:
            builtins.listToAttrs (builtins.map
              (x: { name = type + "/" + x; value = program; })
              subt);
        in
        [
          { "text/plain" = "nvim.desktop"; }
          { "application/zip" = "org.gnome.FileRoller.desktop"; }
          { "application/rar" = "org.gnome.FileRoller.desktop"; }
          { "application/7z" = "org.gnome.FileRoller.desktop"; }
          { "application/*tar" = "org.gnome.FileRoller.desktop"; }
          { "inode/directory" = "pcmanfm.desktop"; }
          { "video/*" = "mpv.desktop"; }
          { "audio/*" = "org.gnome.Lollypop.desktop"; }
          { "x-scheme-handler/tg" = "ferdium.desktop"; }
          { "text/html" = "brave.desktop"; }
          { "x-scheme-handler/http" = "brave.desktop"; }
          { "x-scheme-handler/https" = "brave.desktop"; }
          { "x-scheme-handler/ftp" = "brave.desktop"; }
          { "x-scheme-handler/chrome" = "brave.desktop"; }
          { "x-scheme-handler/about" = "brave.desktop"; }
          { "x-scheme-handler/unknown" = "brave.desktop"; }
          { "application/x-extension-htm" = "brave.desktop"; }
          { "application/x-extension-html" = "brave.desktop"; }
          { "application/x-extension-shtml" = "brave.desktop"; }
          { "application/xhtml+xml" = "brave.desktop"; }
          { "application/x-extension-xhtml" = "brave.desktop"; }
          { "application/x-extension-xht" = "brave.desktop"; }
          (subtypes "image" "imv-dir.desktop"
            [ "png" "jpeg" "gif" "svg" "svg+xml" "tiff" "x-tiff" "x-dcraw" ])
        ]
      );
  };
}
