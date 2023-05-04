{ inputs, config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kitty # gpu accelerated terminal
    wayland
    wlr-randr
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursors
    swaylock
    swayidle
    imagemagick
    pkgs.sway-contrib.grimshot
    flameshot
    grim
    libnotify
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    wdisplays # tool to configure displays
    wev
    polkit_gnome
    brave

    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    inputs.hyprpicker.packages.${pkgs.system}.hyprpicker
    swaylock-effects
    pamixer
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services = {
    dbus.packages = [ pkgs.gcr ];
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs = {
    dconf.enable = true;
    light.enable = true;
  };

  security.pam.services.swaylock = { };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
