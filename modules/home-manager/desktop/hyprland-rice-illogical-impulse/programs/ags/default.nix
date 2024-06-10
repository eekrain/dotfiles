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
      glib
      ollama
      pywal
      sassc
      (python312.withPackages (p: [
        p.material-color-utilities
        p.pywayland
      ]))
      python-materialyoucolor

      brightnessctl
      ydotool
      ddcutil
      dart-sass
      material-symbols
      playerctl
      gojq
      yad
      bc
      gradience
    ];

    programs.ags = {
      enable = true;

      # null or path, leave as null if you don't want hm to manage the config
      configDir = null;

      # additional packages to add to gjs's runtime
      extraPackages = with pkgs; [
        gtksourceview
        gtksourceview4
        gtksourceviewmm
        gtkmm3
        webkitgtk
        accountsservice
        gtk-layer-shell
        tinyxml-2

        ollama
        python312Packages.material-color-utilities
        python312Packages.pywayland
        python-materialyoucolor
        pywal
        webp-pixbuf-loader
      ];
    };
  };
}
