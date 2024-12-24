mkdir -p ~/.config/hypr/hyprland && rsync -avz ~/.config.example/hyprland ~/.config/hypr --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
rsync -avz ~/.config.example/ags ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
rsync -avz ~/.config.example/fuzzel ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
rsync -avz ~/.config.example/qt5ct ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
# Starting hyprland
pidof Hyprland || Hyprland
