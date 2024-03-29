{ config, pkgs, lib, inputs, user, ... }:

{
  home.packages = with pkgs; [
    hicolor-icon-theme
    gnome.adwaita-icon-theme
    kora-icon-theme
  ];

  home.sessionVariables = {
    GTK_THEME = "Catppuccin-Mocha-Compact-Pink-Dark";
    XCURSOR_THEME = "Catppuccin-Mocha-Pink-Cursors";
  };
  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaPink;
    name = "Catppuccin-Mocha-Pink-Cursors";
    size = 32;
  };
  home.pointerCursor.gtk.enable = true;
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "mocha";
      };
    };

    cursorTheme = {
      name = "Catppuccin-Mocha-Pink-Cursors";
      size = 32;
    };

    iconTheme = {
      name = "Oranchelo";
      package = pkgs.oranchelo-icon-theme;
    };

    font = {
      name = "DM Sans";
      size = 12;
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
