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
      ollama
      pywal
      sassc
      (python312.withPackages (p: [
        p.material-color-utilities
        p.pywayland
      ]))

      brightnessctl
      ydotool
    ];

    programs.ags = {
      enable = true;

      # null or path, leave as null if you don't want hm to manage the config
      configDir = null;

      # additional packages to add to gjs's runtime
      extraPackages = with pkgs; [
        gtksourceview
        gtksourceview4
        webkitgtk
        accountsservice

        ollama
        python311Packages.material-color-utilities
        python311Packages.pywayland
        pywal
        sassc
        webp-pixbuf-loader
        ydotool
      ];
    };
  };
}
