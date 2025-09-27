# Caelestia Implementation Guide

## Overview
This guide provides step-by-step instructions for implementing Caelestia integration in your NixOS Home Manager modules, based on the plan outlined in `caelestia-integration-plan.md`.

## Prerequisites

Before implementing Caelestia, ensure you have:
1. A working NixOS system with your current configuration
2. Home Manager properly set up and working
3. Hyprland installed and configured
4. UWSM (Universal Wayland Session Manager) working with your current setup

## Step 1: Add Caelestia to Flake Inputs

First, update your `flake.nix` to include Caelestia and its dependencies:

```nix
# Add to inputs section in flake.nix
inputs = {
  # Existing inputs...
  caelestia.url = "github:caelestia-dots/shell";
  caelestia.inputs.nixpkgs.follows = "nixpkgs";
  
  quickshell = {
    url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

After updating the inputs, run:
```bash
nix flake update
```

## Step 2: Create Caelestia Module Directory Structure

Create the necessary directory structure for the Caelestia module:

```bash
mkdir -p modules/home-manager/caelestia
```

## Step 3: Implement Caelestia Configuration Files

### 3.1 Main Module Entry Point

Create `modules/home-manager/caelestia/default.nix`:

```nix
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.caelestia.homeManagerModules.default
    ./configuration.nix
    ./packages.nix
    ./theme.nix
  ];

  # Enable Caelestia
  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
  };

  # Integration with UWSM
  home.file.".config/uwsm/env-caelestia" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Caelestia specific environment variables
      export XDG_CURRENT_DESKTOP="Caelestia"
      export XDG_SESSION_DESKTOP="Caelestia"
      
      # Toolkit backend variables
      export GDK_BACKEND="wayland,x11,*"
      export QT_QPA_PLATFORM="wayland;xcb"
      export SDL_VIDEODRIVER="wayland"
      export CLUTTER_BACKEND="wayland"
      
      # Theming variables
      export GTK_THEME="Nordic"
      export XCURSOR_THEME="Bibata-Modern-Classic"
      export XCURSOR_SIZE="24"
      
      # Qt platform theme
      export QT_QPA_PLATFORMTHEME="qt5ct"
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      
      # NixOS specific
      export NIXOS_OZONE_WL="1"
      export ELECTRON_OZONE_PLATFORM_HINT="auto"
    '';
  };
}
```

### 3.2 Configuration Settings

Create `modules/home-manager/caelestia/configuration.nix`:

```nix
{ config, lib, ... }: {
  programs.caelestia.settings = {
    # Appearance settings
    appearance = {
      anim = {
        durations = {
          scale = 0.7;
        };
      };
      padding = {
        scale = 0.5;
      };
      transparency = {
        enabled = true;
        base = 0.6;
        layers = 0.4;
      };
    };

    # General settings
    general = {
      apps = {
        terminal = [ "ghostty" ];
        audio = [ "pavucontrol" ];
      };
    };

    # Background settings
    background = {
      desktopClock = {
        enabled = true;
      };
    };

    # Bar configuration
    bar = {
      sizes = {
        innerWidth = 32;
      };
      status = {
        showAudio = true;
        showMicrophone = true;
      };
      tray = {
        recolour = false;
      };
      workspaces = {
        activeLabel = "";
        label = "";
        occupiedLabel = "";
        shown = 5;
      };
    };

    # Border settings
    border = {
      thickness = 1;
    };

    # Dashboard settings
    dashboard = {
      dragThreshold = 10;
    };

    # Launcher settings
    launcher = {
      vimKeybinds = true;
      enableDangerousActions = true;
      maxShown = 10;
    };

    # Notification settings
    notifs = {
      actionOnClick = true;
      defaultExpireTimeout = 3000;
    };

    # OSD settings
    osd = {
      hideDelay = 1000;
    };

    # Session settings
    session = {
      vimKeybinds = true;
      commands = {
        logout = [ "loginctl" "terminate-user" "" ];
        shutdown = [ "systemctl" "poweroff" ];
        hibernate = [ "systemctl" "hibernate" ];
        reboot = [ "systemctl" "reboot" ];
      };
    };
  };

  # Enable CLI
  programs.caelestia.cli = {
    enable = true;
  };
}
```

### 3.3 Required Packages

Create `modules/home-manager/caelestia/packages.nix`:

```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Caelestia dependencies
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    hyprpicker
    hypridle
    wl-clipboard
    cliphist
    bluez
    bluez-tools
    inotify-tools
    app2unit
    wireplumber
    trash-cli
    foot
    fish
    fastfetch
    starship
    btop
    jq
    socat
    imagemagick
    curl
    adw-gtk3
    papirus-icon-theme
    kdePackages.qt6ct
    libsForQt5.qt5ct
    nerd-fonts.jetbrains-mono
    
    # Additional utilities
    quickshell
    swww
    grimblast
    satty
  ];
}
```

### 3.4 Theme Integration

Create `modules/home-manager/caelestia/theme.nix`:

```nix
{ config, lib, pkgs, ... }: {
  # Integration with existing theming system
  home.sessionVariables = {
    # Caelestia theme variables
    CAELESTIA_THEME = "nordic";
    CAELESTIA_ACCENT = "blue";
  };
  
  # Theme switching script
  home.packages = with pkgs; [
    (writeShellScriptBin "caelestia-theme-switch" ''
      #!/bin/sh
      # Theme switching script for Caelestia
      case $1 in
        "light")
          theme="solarized-light"
          ;;
        "dark")
          theme="solarized-dark"
          ;;
        *)
          theme="nordic"
          ;;
      esac
      
      # Update Caelestia theme
      caelestia-cli theme set "$theme"
      
      # Restart Caelestia to apply theme
      systemctl --user restart caelestia
    '')
  ];
}
```

## Step 4: Update Home Manager Default Configuration

Update `modules/home-manager/default.nix` to include the Caelestia module:

```nix
{
  imports = [
    ./default-settings.nix
    ./cli
    ./programs
    ./addons
    ./illogical-impulse-quickshell
    ./caelestia  # Add this line
  ];
  
  # Add Caelestia to module options
  myHmModules = {
    # Existing modules...
    caelestia = {
      enable = lib.mkEnableOption "Enable Caelestia desktop environment";
    };
  };
}
```

## Step 5: Update User Configuration

Update `home-manager/eekrain.nix` to enable Caelestia:

```nix
{
  # Existing configuration...
  
  myHmModules = {
    # Existing modules...
    caelestia = {
      enable = true;
    };
  };
}
```

## Step 6: Update NixOS System Configuration

Update `modules/nixos/desktop/hyprland.nix` to add Caelestia support:

```nix
{
  config = mkIf cfg.enable {
    # Existing configuration...
    
    # Add Caelestia dependencies
    environment.systemPackages = with pkgs; [
      # Existing packages...
      caelestia
    ];
    
    # Enable required services
    services = {
      # Existing services...
      upower.enable = true;  # Required by Caelestia
    };
  };
}
```

## Step 7: Build and Test

### 7.1 Update Flake Lock

```bash
nix flake update
```

### 7.2 Build Home Manager Configuration

```bash
home-manager switch --flake .#eekrain@eka-laptop
```

### 7.3 Build NixOS Configuration

```bash
nixos-rebuild switch --flake .#eka-laptop
```

## Step 8: Verify Installation

### 8.1 Check Service Status

```bash
systemctl --user status caelestia
```

### 8.2 Check Caelestia CLI

```bash
caelestia-cli --help
```

### 8.3 Test Theme Switching

```bash
caelestia-theme-switch dark
caelestia-theme-switch light
```

## Step 9: Troubleshooting

### Common Issues and Solutions

#### 1. Caelestia Service Not Starting

**Problem**: Caelestia service fails to start
**Solution**: 
```bash
# Check service logs
journalctl --user -u caelestia

# Check dependencies
systemctl --user status hyprland-session.target
```

#### 2. Theme Issues

**Problem**: Themes not applying correctly
**Solution**:
```bash
# Verify theme files exist
ls -la ~/.config/caelestia/themes/

# Check theme configuration
caelestia-cli theme list
```

#### 3. Keybinding Conflicts

**Problem**: Keybindings not working or conflicting with existing setup
**Solution**:
```bash
# Check current keybindings
caelestia-cli keybindings list

# Check Hyprland keybindings
hyprctl keybindings
```

#### 4. Performance Issues

**Problem**: Caelestia using too many resources
**Solution**:
Adjust transparency and animation settings in `configuration.nix`:
```nix
transparency = {
  enabled = true;
  base = 0.8;  # Reduce transparency
  layers = 0.6;
};
```

## Step 10: Integration with Existing Setup

### 10.1 Coexistence with illogical-impulse-quickshell

To use both Caelestia and illogical-impulse-quickshell:

1. Create a startup script that launches both
2. Configure them to use different workspaces or areas
3. Adjust keybindings to avoid conflicts

### 10.2 Migration Strategy

For full migration from illogical-impulse-quickshell to Caelestia:

1. Backup existing configuration
2. Disable illogical-impulse-quickshell in user configuration
3. Enable Caelestia
4. Migrate custom settings and preferences
5. Test thoroughly

## Conclusion

This implementation guide provides a comprehensive approach to integrating Caelestia into your NixOS configuration. The modular design ensures compatibility with your existing setup while allowing for future customization and enhancement.

Remember to test each step thoroughly and make backups before making significant changes to your configuration.