{ config, lib, pkgs, ... }:

{
  imports = [
    ./theme/catppuccin-dark
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;
    nvidiaPatches = false;
    extraConfig = ''
      $mainMod = WIN
      monitor=,preferred,auto,1 

      bind = $mainMod, Return, exec, kitty zsh
      bind = $mainMod SHIFT, Return, exec, kitty --class="termfloat" zsh
      bind = $mainMod SHIFT, P, killactive,
      bind = $mainMod SHIFT, Q, exit,
      bind = $mainMod SHIFT, Space, togglefloating,
      bind = $mainMod,F,fullscreen
      bind = $mainMod,Y,pin
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle
    '';
  };
}
