{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.desktop.hyprland;
in {
  # add the home manager module
  imports = [inputs.ags.homeManagerModules.default];

  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    home.packages = with pkgs; [
      # Python
      pyenv.out
      (python311.withPackages (p:
        with p; [
          materialyoucolor
          setproctitle
          material-color-utilities
          pywal
          pywayland
          pygobject3
        ]))

      # MicroTex Deps
      tinyxml-2
      gtkmm3
      gtksourceviewmm
      cairomm

      # Gnome Stuff
      gnome.gnome-control-center
      gnome.gnome-bluetooth
      gnome.gnome-shell
      blueberry

      # GTK
      webp-pixbuf-loader
      gtk-layer-shell
      gtk3
      gtksourceview3
      upower
      gobject-introspection

      # AGS and Hyprland dependencies.
      brightnessctl
      glib
      material-symbols
      ddcutil
      fuzzel
      ripgrep
      gojq
      dart-sass
      sassc
      axel
      hyprpicker
      gammastep
      bc
      gradience
      playerctl
      yad
      ydotool
      xdg-user-dirs
    ];

    programs.ags = {
      enable = true;

      # null or path, leave as null if you don't want hm to manage the config
      configDir = null;

      # additional packages to add to gjs's runtime
      extraPackages = with pkgs; [
        pkgs2311.gtksourceview
        pkgs2311.gnome.gvfs
        webkitgtk
        accountsservice
      ];
    };

    # For the zsh implementing terminal colors
    # that's autogenerated by changing wallpaper
    programs.zsh.initExtra = ''
      if test -f ~/.cache/ags/user/generated/terminal/sequences.txt; then
        cat ~/.cache/ags/user/generated/terminal/sequences.txt
      fi
    '';
  };
}
