{ pkgs, ... }:
let
  hypr_autostart = pkgs.writeShellScriptBin "hypr_autostart" ''
    config=$HOME/.config/hypr
    scripts=$config/scripts

    dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_DATA_DIRS && systemctl --user start hyprland-session.target
    configure-gtk

    systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr

    # notification daemon
    dunst &

    # waybar
    waybar&
    $scripts/tools/dynamic &

    # u can change default suspend mode here
    echo "home" > /tmp/suspend_mode
    myswayidle &

    # wallpaper
    swww init

    # other
    $scripts/toggle_touchpad disable &
    notify-send -a aurora "hello $(whoami)" &

    # wl clip util
    wl-clip-persist --clipboard regular &

    gtk-launch spotify.desktop &
    gtk-launch rambox.desktop &
    gtk-launch motrix.desktop &
    gtk-launch brave-browser.desktop &
    sleep 5
    hyprctl dispatch workspace 1
  '';
  hypr_kill = pkgs.writeShellScriptBin "hypr_kill" ''
    pkill -15 swww-daemon
    if [ -f /run/user/1000/swww.socket ]
    then
      rm /run/user/1000/swww.socket
    fi
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
      --fade-in 0.3 &
  '';
  myswayidle = pkgs.writeShellScriptBin "myswayidle" ''
    if [ ! -f /tmp/suspend_mode ]
    then
      echo "work" > /tmp/suspend_mode
    fi

    SUSPEND_MODE=$(</tmp/suspend_mode)

    if [ $SUSPEND_MODE = "work" ]
    then
      swayidle -w \
        timeout 30                          "hyprctl dispatch dpms off" \
        resume                              "hyprctl dispatch dpms on" \
        timeout 60                          "hyprctl dispatch dpms on && myswaylock" \
        timeout 65                          "hyprctl dispatch dpms off" \
        timeout 300                         "systemctl suspend" \
        before-sleep                        "hyprctl dispatch dpms on" &
    else
      swayidle -w \
        timeout 120                          "hyprctl dispatch dpms off" \
        resume                              "hyprctl dispatch dpms on" \
        timeout 300                         "hyprctl dispatch dpms on && myswaylock" \
        timeout 305                         "hyprctl dispatch dpms off" \
        timeout 600                         "systemctl suspend" \
        before-sleep                        "hyprctl dispatch dpms on" &
    fi
  '';
  cycle-suspend-mode = pkgs.writeShellScriptBin "cycle-suspend-mode" ''
    SUSPEND_MODE=$(</tmp/suspend_mode)
    # set all suspend mode that registered
    all_mode=("work" "home")
    indexes=( "''${!all_mode[@]}")
    lastIndex=''${indexes[-1]}

    # find current index
    for i in "''${!all_mode[@]}"; do
      if [[ "''${all_mode[$i]}" = $SUSPEND_MODE ]]; then
        current_index=$i
      fi
    done
    # add one to new index
    new_index=$(($current_index + 1))

    if [ $new_index -gt $lastIndex ]; then
      # cycle back to the first mode
      new_index=0
    fi

    # write the new mode
    echo ''${all_mode[$new_index]} > /tmp/suspend_mode

    # restart the swayidle
    pkill swayidle
    myswayidle &

    notify-send -u critical -t 3000 "Suspend Mode" "Suspend mode changed to ''${all_mode[$new_index]}"
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
    text = ''
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme "Catppuccin-Mocha-Compact-Pink-Dark"
      gsettings set $gnome_schema icon-theme "Oranchelo"
      gsettings set $gnome_schema cursor-theme "Catppuccin-Mocha-Pink-Cursors"
      gsettings set $gnome_schema font-name "DM Sans 12"
      gsettings set $gnome_schema cursor-size "32"
      gsettings set $gnome_schema font-antialiasing "1"
    '';
  };
  wall = pkgs.writeShellScriptBin "wall" ''
    swww init
    swww img $1 --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
  '';
in
{
  imports = [
    ./hypr-variables.nix
    ./hyprland-conf.nix
  ];

  home.packages = with pkgs; [
    waybar-mpris
    swww
    wall
    hypr_autostart
    myswaylock
    myswayidle
    configure-gtk
    hypr_kill
    cycle-suspend-mode
  ];

  xdg.configFile."hypr/scripts".source = ./scripts;
  xdg.configFile."hypr/scripts".recursive = true;
  xdg.configFile."hypr/wallpapers".source = ./wallpapers;
  xdg.configFile."hypr/wallpapers".recursive = true;

  home.sessionVariables = {
    XDG_DATA_DIRS =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      "${datadir}:$XDG_DATA_DIRS";
  };
}
