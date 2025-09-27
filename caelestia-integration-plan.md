# Caelestia Integration Implementation Plan

## Overview
This document outlines the implementation plan for integrating Caelestia into your NixOS Home Manager modules, based on the reference configuration from mawkler-nixos and adapted to your modular architecture.

## Implementation Steps

### 1. Add Caelestia to Flake Inputs
**File**: `flake.nix`

**Changes Required**:
```nix
inputs = {
  # Existing inputs...
  caelestia.url = "github:caelestia-dots/shell";
  caelestia.inputs.nixpkgs.follows = "nixpkgs";
  
  # Additional dependencies for Caelestia
  quickshell = {
    url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### 2. Create Caelestia Home Manager Module Structure
**Directory Structure**:
```
modules/home-manager/caelestia/
├── default.nix              # Main module entry point
├── configuration.nix        # Caelestia configuration settings
├── packages.nix           # Required packages and dependencies
└── theme.nix              # Theming integration
```

### 3. Implement Caelestia Configuration
**File**: `modules/home-manager/caelestia/default.nix`

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

  # Integration with UWSM (similar to illogical-impulse-quickshell)
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

### 4. Configure Caelestia Settings
**File**: `modules/home-manager/caelestia/configuration.nix`

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

### 5. Define Required Packages
**File**: `modules/home-manager/caelestia/packages.nix`

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

### 6. Theme Integration
**File**: `modules/home-manager/caelestia/theme.nix`

```nix
{ config, lib, pkgs, ... }: {
  # Integration with existing theming system
  # This can be expanded to work with Stylix or other theming solutions
  
  home.sessionVariables = {
    # Caelestia theme variables
    CAELESTIA_THEME = "nordic";
    CAELESTIA_ACCENT = "blue";
  };
  
  # Optional: Create theme switching script
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

### 7. Update Home Manager Default Configuration
**File**: `modules/home-manager/default.nix`

**Changes Required**:
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

### 8. Update User Configuration
**File**: `home-manager/eekrain.nix`

**Changes Required**:
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

### 9. Update NixOS System Configuration
**File**: `modules/nixos/desktop/hyprland.nix`

**Changes Required**:
Add Caelestia-related packages and services:

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

## Testing and Validation

### 1. Build Test
```bash
# Test Home Manager configuration
home-manager switch --flake .#eekrain@eka-laptop

# Test NixOS configuration
nixos-rebuild switch --flake .#eka-laptop
```

### 2. Functionality Test
- Verify Caelestia starts automatically
- Test all configured features (bar, launcher, notifications, etc.)
- Verify theme integration
- Test keybindings and shortcuts

### 3. Integration Test
- Verify compatibility with existing illogical-impulse-quickshell
- Test UWSM integration
- Verify Hyprland compatibility

## Migration Strategy

### Option 1: Side-by-Side Installation
- Install Caelestia alongside existing setup
- Allow switching between desktop environments
- Test thoroughly before full migration

### Option 2: Full Replacement
- Replace illogical-impulse-quickshell with Caelestia
- Migrate all configurations and customizations
- Complete switch to Caelestia

### Option 3: Hybrid Approach
- Use Caelestia for specific features
- Keep illogical-impulse-quickshell for others
- Create custom integration between both systems

## Troubleshooting

### Common Issues
1. **Caelestia not starting**: Check systemd service status and dependencies
2. **Theme issues**: Verify theme configuration and file paths
3. **Keybinding conflicts**: Check for conflicts with existing Hyprland keybindings
4. **Performance issues**: Adjust transparency and animation settings

### Debug Commands
```bash
# Check Caelestia service status
systemctl --user status caelestia

# Check Caelestia logs
journalctl --user -u caelestia

# Test Caelestia CLI
caelestia-cli --help

# Verify Hyprland integration
hyprctl clients
```

## Conclusion

This implementation plan provides a comprehensive approach to integrating Caelestia into your NixOS configuration. The modular design ensures compatibility with your existing setup while allowing for future customization and enhancement.

The key to success is careful implementation and testing, particularly around the integration with your existing illogical-impulse-quickshell setup and UWSM session management.