{ config, pkgs, lib, ... }:
let
  inherit (lib) fileContents;
in
{
  environment.systemPackages = with pkgs; [
    # hyprland spesific
    wayland
    wayland-scanner
    wayland-utils
    wayland-protocols
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5ct
    qt6.qtbase
    glib # gsettings
    xdg-utils # for opening default programs when clicking links
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wl-clip-persist
    #other pkgs
    sddm-sugar-candy
    wev
    wlr-randr
    libnotify
    sshpass
    polkit_gnome
    eza
    fzf
    python3
    jq
    swaylock-effects
    swayidle
    ffmpeg
    gtk3
  ];
  #environment.variables.NIXOS_OZONE_WL = "1";

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  environment.shellInit = ''
    export STARSHIP_CONFIG=${
      pkgs.writeText "starship.toml"
      (fileContents ./starship.toml)
    }
  '';
}
