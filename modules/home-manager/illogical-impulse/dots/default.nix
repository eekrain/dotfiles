{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./theme];

  # Copy all the files from this dots folder
  # For applying the config we still need to copy over manually not nix managed
  # because illogical impulse's ags needs some write access
  home.file.".config.example" = {
    source = "./";
    executable = true; # make all files executable
  };

  home.packages = [
    # This scripts is used to init illogical-impulse dotfiles
    # It copies from the reference dot files located ~/.config.example as we already set above
    # Run it from cli "init-illogical-impulse"
    (pkgs.writeShellScriptBin "init-illogical-impulse" ''
      mkdir -p ~/.config/hypr/hyprland && cp -rfL ~/.config.example/hyprland ~/.config/hypr
      cp -rfL ~/.config.example/ags ~/.config
      cp -rfL ~/.config.example/fuzzle ~/.config
      cp -rfL ~/.config.example/qt5ct ~/.config

      # Starting hyprland
      pidof Hyprland || Hyprland
    '')
  ];
}
