{ config, lib, pkgs, ... }: {
  # Integration with existing theming system
  home.sessionVariables = {
    # Caelestia theme variables
    CAELESTIA_THEME = "nordic";
    CAELESTIA_ACCENT = "blue";
  };
}