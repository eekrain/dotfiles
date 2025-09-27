{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./programs
    ./dots.nix
    ./theme.nix
  ];

  home.packages = with pkgs; [
    clipse
    wl-clip-persist
    grimblast
    satty
    swww
    quickshell
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;

    extraConfig = ''
      exec-once = qs &
      exec-once = swww-daemon --format xrgb
      exec-once = ${pkgs.clipse}/bin/clipse -listen
      exec-once = ${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular
      
      source=~/.config/hypr/hyprland/general.conf
      source=~/.config/hypr/hyprland/env.conf
      source=~/.config/hypr/hyprland/execs.conf
      source=~/.config/hypr/hyprland/rules.conf
      source=~/.config/hypr/hyprland/keybinds.conf
    '';
  };
}
