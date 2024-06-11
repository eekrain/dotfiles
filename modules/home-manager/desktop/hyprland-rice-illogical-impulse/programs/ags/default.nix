{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  # add the home manager module
  imports = [ inputs.ags.homeManagerModules.default ];

  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    home.packages = with pkgs; [
      # Python
      pyenv.out
      (python311.withPackages (p: with p; [
        materialyoucolor
        material-color-utilities
        pillow
        poetry-core
        pywal
        setuptools-scm
        wheel
        pywayland
        psutil
        # debugpy.overrideAttrs (final: prev: {
        #   pytestCheckPhase = ''true'';
        # })
        pydbus
        dbus-python
        pygobject3
        watchdog
        pip
        evdev
        appdirs
        inotify-simple
        ordered-set
        six
        hatchling
        pycairo
        xkeysnail
      ]))

      # MicroTex Deps
      tinyxml-2
      gtkmm3
      gtksourceviewmm
      cairomm

      # Gnome Stuff
      polkit_gnome
      gnome.gnome-control-center
      gnome.gnome-bluetooth
      gnome.gnome-shell
      blueberry
      wlsunset

      # GTK
      webp-pixbuf-loader
      gtk-layer-shell
      gtk3
      gtksourceview3
      upower
      gobject-introspection
      wrapGAppsHook

      # AGS and Hyprland dependencies.
      glib
      material-symbols
      brightnessctl
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
  };
}
