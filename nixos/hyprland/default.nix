{ inputs, config, pkgs, ... }:
{
  imports = [
    ./core.nix
    ./fonts.nix
  ];
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.defaultSession = "hyprland";
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.enableHidpi = true;
  services.xserver.displayManager.sddm.theme = "sugar-candy";
  services.xserver.displayManager.sddm.stopScript = ''
    pkill -15 swww-daemon
    pkill -9 Hyprland
    if [ -f /run/user/1000/swww.socket ]
    then
      rm /run/user/1000/swww.socket
    fi
  '';

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    nvidiaPatches = true;
  };

  services = {
    dbus.packages = [ pkgs.gcr ];
    gvfs.enable = true;
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    light.enable = true;
  };

  security.pam.services.swaylock = { };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  security.doas = {
    enable = true;
    extraConfig = ''
      permit nopass :wheel
    '';
  };
}
