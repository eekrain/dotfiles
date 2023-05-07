{ config, pkgs, lib, ... }:
let
  inherit (lib) fileContents;
in
{
  environment.systemPackages = with pkgs; [
    # hyprland spesific
    wl-clipboard
    wayland
    wayland-scanner
    wayland-utils
    wayland-protocols
    egl-wayland
    glfw-wayland
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5ct
    #other pkgs
    sddm-sugar-candy
    wev
    wlr-randr
    libnotify
    gnome.nautilus
    sshpass
    polkit_gnome
    exa
    fzf
    python39
    jq
  ];
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
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

  environment.shellInit = ''
    export STARSHIP_CONFIG=${
      pkgs.writeText "starship.toml"
      (fileContents ./starship.toml)
    }
  '';
}
