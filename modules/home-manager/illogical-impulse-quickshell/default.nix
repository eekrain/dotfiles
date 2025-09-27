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
    packageSet = "essential";
    mode = "hybrid";  # Hyprland declarative + Quickshell copied
    
    # Force disable touchegg component (handle system-wide if needed)
    touchegg.enable = lib.mkForce false;
    
    # Enable misc config copying to get Quickshell files deployed
    configuration.copyMiscConfig = lib.mkForce true;
    
    # Quickshell configuration customized for existing setup
    quickshell = {
      appearance = {
        extraBackgroundTint = true;
        fakeScreenRounding = 2;
        transparency = false;
      };
      
      bar = {
        bottom = false;          # Top bar
        cornerStyle = 0;         # Hug style
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
        bluetooth = "kcmshell6 kcm_bluetooth";
        network = "plasmawindowed org.kde.plasma.networkmanagement";
        taskManager = "plasma-systemmonitor --page-name Processes";
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