{
  config,
  lib,
  pkgs,
  ...
}: {
  # Integration with existing theming system
  home.sessionVariables = {
    # Caelestia theme variables
    CAELESTIA_THEME = "nordic";
    CAELESTIA_ACCENT = "blue";
  };

  # Enable Hyprcursor Phinger cursor theme
  programs.hyprcursor-phinger = {
    enable = true;
  };
}
