{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  # Copy all the files from this dots folder
  # For applying the config we still need to copy over manually not nix managed
  # because illogical impulse's ags needs some write access
  home.file.".config.example" = {
    source = ./dots;
    executable = true; # make all files executable
  };

  home.packages = [
    # This scripts is used to init illogical-impulse dotfiles
    # It copies from the reference dot files located ~/.config.example as we already set above
    # Run it from cli "init-illogical-impulse"
    (pkgs.writeShellScriptBin "init-illogical-impulse" ''
      mkdir -p ~/.config/hypr/hyprland && rsync -avz ~/.config.example/hyprland ~/.config/hypr --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      rsync -avz ~/.config.example/ags ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      rsync -avz ~/.config.example/fuzzel ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      rsync -avz ~/.config.example/qt5ct ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      # Starting hyprland
      pidof Hyprland || Hyprland
    '')
  ];
}
