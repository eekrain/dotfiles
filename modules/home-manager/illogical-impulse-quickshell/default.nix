{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    inputs.illogical-impulse-quickshell.homeManagerModules.default
  ];

  # dots-hyprland configuration - HYBRID MODE
  programs.dots-hyprland = {
    enable = true;
    source = ./configs;
    packageSet = "minimal";
    mode = "declarative";
    touchegg.enable = lib.mkForce false;
    # Quickshell configuration customized for existing setup
    quickshell = {
      appearance = {
        fakeScreenRounding = 2;
        transparency = false;
      };
      
      bar = {
        bottom = false;          # Top bar
        cornerStyle = 2;         # Hug style
        topLeftIcon = "spark";
        showBackground = true;
        verbose = true;
        
        utilButtons = {
          showScreenSnip = true;
          showColorPicker = true;
          showMicToggle = true;
          showKeyboardToggle = true;
          showDarkModeToggle = true;
          showPerformanceProfileToggle = false;
        };
        
        workspaces = {
          monochromeIcons = true;
          shown = 10;
          showAppIcons = true;
          alwaysShowNumbers = false;
          showNumberDelay = 300;
        };
      };
      
      battery = {
        low = 20;
        critical = 5;
        automaticSuspend = true;
        suspend = 3;
      };
      
      apps = {
        terminal = "kitty";     # Use existing kitty terminal
        taskManager = "btop";
      };
      
      time = {
        format = "hh:mm";
        dateFormat = "ddd, dd/MM";
      };
    };
  };

  # Additional packages that work with Quickshell setup
  home.packages = with pkgs; [
    clipse
    wl-clip-persist
    grimblast
    satty
    swww
    quickshell
  ];
}
