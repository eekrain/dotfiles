{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.default
  ];

  # Enable hyprcursor-phinger from the flake
  programs.hyprcursor-phinger.enable = true;

  # Set Hyprcursor environment variables
  home.sessionVariables = {
    HYPRCURSOR_THEME = "phinger-cursors-dark";
    HYPRCURSOR_SIZE = "24";
  };
  # Set up the traditional Xcursor theme for GTK applications
  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;

    cursorTheme = {
      name = "phinger-cursors-dark";
      size = 24;
    };

    theme = {
      package = pkgs.graphite-gtk-theme.override {
        themeVariants = ["purple"];
        colorVariants = ["dark"];
      };
      name = "Graphite-purple-dark"; # folder inside share/themes
    };

    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };

    font = {
      name = "Rubik";
      package = pkgs.rubik;
      size = 11;
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
}
