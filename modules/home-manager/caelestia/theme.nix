{ config, lib, pkgs, ... }: {
  # Integration with existing theming system
  home.sessionVariables = {
    # Caelestia theme variables
    CAELESTIA_THEME = "nordic";
    CAELESTIA_ACCENT = "blue";
  };
  
  # Theme switching script
  home.packages = with pkgs; [
    (writeShellScriptBin "caelestia-theme-switch" ''
      #!/bin/sh
      # Theme switching script for Caelestia
      case $1 in
        "light")
          theme="solarized-light"
          ;;
        "dark")
          theme="solarized-dark"
          ;;
        *)
          theme="nordic"
          ;;
      esac
      
      # Update Caelestia theme
      caelestia-cli theme set "$theme"
      
      # Restart Caelestia to apply theme
      systemctl --user restart caelestia
    '')
  ];
}