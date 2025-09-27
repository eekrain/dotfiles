{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  # Copy all the files from this dots folder
  # For applying the config we still need to copy over manually not nix managed
  # because quickshell needs some write access
  home.file.".config.example-quickshell" = {
    source = ./dots;
    executable = true; # make all files executable
  };

  home.packages = [
    # This scripts is used to init illogical-impulse-quickshell dotfiles
    # It copies from the reference dot files located ~/.config.example-quickshell as we already set above
    # Run it from cli "init-illogical-impulse-quickshell"
    (pkgs.writeShellScriptBin "init-illogical-impulse-quickshell" ''
      mkdir -p ~/.config/hypr/hyprland && rsync -avz ~/.config.example-quickshell/hyprland ~/.config/hypr --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      rsync -avz ~/.config.example-quickshell/quickshell ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      rsync -avz ~/.config.example-quickshell/applications ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      # Starting hyprland
      pidof Hyprland || Hyprland
    '')
  ];
}