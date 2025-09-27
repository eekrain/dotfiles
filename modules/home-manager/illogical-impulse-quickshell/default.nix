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
    systemd.enable = true;

    settings = {
      # Essential environment variables for Wayland
      env = [
        "XDG_RUNTIME_DIR,/run/user/$UID"
        "WAYLAND_DISPLAY,wayland-0"
        "XDG_SESSION_TYPE,wayland"
        "QT_QPA_PLATFORM,wayland-egl"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      ];
    };
    
    extraConfig = ''
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

  # Essential session variables for systemd
  systemd.user.sessionVariables = {
    WAYLAND_DISPLAY = "wayland-0";
    XDG_SESSION_TYPE = "wayland";
  };

  # Home manager session variables
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland-egl";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
}
