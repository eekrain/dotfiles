{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModule.desktop.hyprland;
in
{
  options.myModule.desktop.hyprland.enable = mkEnableOption "Enable basic hyprland installation";

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
      systemd.setPath.enable = true;
    };

    programs = {
      dconf.enable = true;
      light.enable = true;
    };

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      egl-wayland
      #other pkgs
      xdg-utils # for opening default programs when clicking links
      swww # wallpaper daemon
      gtk3 # needed for gtk-launch command
    ];
  };
}
