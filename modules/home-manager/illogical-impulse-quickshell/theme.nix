{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  # Additional stuff
  home.packages = with pkgs; [
    # themes
    libsForQt5.qt5ct
    adw-gtk3
    adwaita-qt6
    material-symbols
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    noto-fonts
    noto-fonts-cjk-sans
    qogir-icon-theme
    adwaita-icon-theme
  ];

  # QT Theming settings
  qt.enable = true;

  # GTK Theming settings
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };

    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };

    gtk2.extraConfig = ''
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';
  };

  # Cursor settings
  programs.hyprcursor-phinger.enable = true;
  home.sessionVariables = {
    HYPRCURSOR_THEME = "phinger-cursors-dark";
    HYPRCURSOR_SIZE = "24";
  };
  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 24;
    gtk.enable = true;
  };
  gtk.cursorTheme = {
    name = "phinger-cursors-dark";
    size = 24;
  };
}