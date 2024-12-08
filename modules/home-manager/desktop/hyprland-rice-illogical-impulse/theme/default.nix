{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.desktop.hyprland;
  # google-fonts = pkgs.google-fonts.override {
  #   fonts = [
  #     "Rubik"
  #     # # Sans
  #     # "Gabarito"
  #     # "Lexend"
  #     # # Serif
  #     # "Chakra Petch"
  #     # "Crimson Text"
  #   ];
  # };
in {
  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
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
        package = pkgs.morewaita-icon-theme;
        name = "MoreWaita";
      };

      font = {
        name = "Rubik";
        package = pkgs.rubik;
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

    # Font linking
    # home.file = {
    #   ".local/share/fonts" = {
    #     recursive = true;
    #     source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
    #   };
    #   ".fonts" = {
    #     recursive = true;
    #     source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
    #   };
    #   ".local/share/icons/MoreWaita".source = "${pkgs.morewaita-icon-theme}/share/icons";
    # };
  };
}
