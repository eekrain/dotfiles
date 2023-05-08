{ pkgs, ... }:
let
  hypr_autostart = pkgs.writeShellScriptBin "hypr_autostart" ''
    config=$HOME/.config/hypr
    scripts=$config/scripts

    # notification daemon
    dunst &

    # waybar
    waybar&
    $scripts/tools/dynamic &

    # wallpaper
    $scripts/wall $config/wallpapers/4.jpg &

    # other
    notify-send -a aurora "hello $(whoami)" &
  '';
  hypr_kill = pkgs.writeShellScriptBin "hypr_kill" ''
    pkill -15 swww-daemon
    rm /run/user/1000/swww.socket
    pkill -15 Hyprland
  '';
  myswaylock = pkgs.writeShellScriptBin "myswaylock" ''
    swaylock  \
      --screenshots \
      --clock \
      --indicator \
      --indicator-radius 100 \
      --indicator-thickness 7 \
      --effect-blur 7x5 \
      --effect-vignette 0.5:0.5 \
      --ring-color 3b4252 \
      --key-hl-color f38ba8 \
      --line-color 89dcebff \
      --inside-color 585b7088 \
      --font "Noto Sans" \
      --text-color cdd6f4ff \
      --separator-color 00000000 \
      --grace 2 \
      --fade-in 0.3
  '';
  myswayidle = pkgs.writeShellScriptBin "myswayidle" ''
    swayidle -w  \
      timeout 60 "myswaylock"\
      timeout 600 "systemctl --suspend-hybrid" \
      timeout 1800 "systemctl hibernate"\
      before-sleep 'myswaylock'
  '';
  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Catppuccin-Mocha-Compact-Pink-Dark'
      '';
  };
in
{
  imports = [
    ./hypr-variables.nix
    ./hyprland-conf.nix
  ];

  home.packages = with pkgs; [
    waybar-mpris
    swww
    hypr_autostart
    myswaylock
    myswayidle
    configure-gtk
    hypr_kill
  ];

  xdg.configFile."hypr/scripts".source = ./scripts;
  xdg.configFile."hypr/scripts".recursive = true;
  xdg.configFile."hypr/wallpapers".source = ./wallpapers;
  xdg.configFile."hypr/wallpapers".recursive = true;
}
