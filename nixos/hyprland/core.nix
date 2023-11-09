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

  security.polkit.enable = true;
  systemd.user.services = {
    polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  environment.shellInit = ''
    export STARSHIP_CONFIG=${
      pkgs.writeText "starship.toml"
      (fileContents ./starship.toml)
    }
  '';
}
