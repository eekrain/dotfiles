# Simplification Plan for illogical-impulse-quickshell

## Current Problems

The current implementation has several complexity issues:

1. **Complex flake dependency**: Relies on `inputs.illogical-impulse-quickshell.homeManagerModules.default` and the complex `programs.dots-hyprland` system
2. **Template-based configuration**: Uses `@VARIABLE@` templates that require complex processing
3. **Over-engineered module system**: The end-4-flakes implementation has too many abstractions
4. **Declarative complexity**: Tries to manage everything through Nix options, making it hard to debug

## Target Structure

Following the `illogical-impulse` pattern:

```
modules/home-manager/illogical-impulse-quickshell/
├── default.nix           # Main module entry point
├── dots.nix             # Configuration file management
├── theme.nix            # Theming and appearance
├── programs/            # Program-specific configurations
│   └── quickshell/      # Quickshell setup
└── dots/                # Actual configuration files
    ├── quickshell/      # Quickshell configs
    ├── hyprland/        # Hyprland configs
    └── applications/    # App configs
```

## Implementation Details

### 1. dots.nix (Configuration File Management)

Based on `illogical-impulse/dots.nix` pattern:

```nix
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  # Copy all the files from dots folder
  home.file.".config.example-quickshell" = {
    source = ./dots;
    executable = true;
  };

  home.packages = [
    # Initialization script
    (pkgs.writeShellScriptBin "init-illogical-impulse-quickshell" ''
      mkdir -p ~/.config/quickshell && rsync -avz ~/.config.example-quickshell/quickshell ~/.config --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      mkdir -p ~/.config/hypr && rsync -avz ~/.config.example-quickshell/hyprland ~/.config/hypr --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      mkdir -p ~/.config/foot && rsync -avz ~/.config.example-quickshell/applications/foot.ini ~/.config/foot/foot.ini --chmod=Du=rwx,Dg=rx,D=rx,Fu=rwx,Fg=rx,Fo=rx
      # Start Quickshell
      pidof qs || qs &
    '')
  ];
}
```

### 2. theme.nix (Theming and Appearance)

Based on `illogical-impulse/theme.nix` pattern:

```nix
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  home.packages = with pkgs; [
    # Themes and icons
    libsForQt5.qt5ct
    adw-gtk3
    material-symbols
    nerd-fonts.fira-code
    qogir-icon-theme
    adwaita-icon-theme
  ];

  # QT Theming
  qt.enable = true;

  # GTK Theming
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };
    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };
  };

  # Cursor settings
  programs.hyprcursor-phinger.enable = true;
  home.sessionVariables = {
    HYPRCURSOR_THEME = "phinger-cursors-dark";
    HYPRCURSOR_SIZE = "24";
  };
}
```

### 3. programs/quickshell/default.nix

```nix
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    quickshell
    swww
    clipse
    wl-clip-persist
    grimblast
    satty
  ];

  # Quickshell autostart
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell shell";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
```

### 4. dots/quickshell/modules/common/Config.qml

Simplified version without complex template system:

```qml
pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string filePath: Directories.shellConfigPath
    property alias options: configOptionsJsonAdapter
    property bool ready: true

    JsonAdapter {
        id: configOptionsJsonAdapter
        
        property JsonObject appearance: JsonObject {
            property bool extraBackgroundTint: true
            property int fakeScreenRounding: 2
            property bool transparency: true
        }

        property JsonObject bar: JsonObject {
            property bool bottom: false
            property int cornerStyle: 1
            property bool showBackground: true
            property bool verbose: true
            
            property JsonObject utilButtons: JsonObject {
                property bool showScreenSnip: true
                property bool showColorPicker: true
                property bool showMicToggle: true
                property bool showKeyboardToggle: true
                property bool showDarkModeToggle: true
            }
            
            property JsonObject workspaces: JsonObject {
                property int shown: 10
                property bool showAppIcons: true
                property bool alwaysShowNumbers: true
                property int showNumberDelay: 100
            }
        }
        
        property JsonObject battery: JsonObject {
            property int low: 25
            property int critical: 10
            property bool automaticSuspend: true
            property int suspend: 5
        }
        
        property JsonObject apps: JsonObject {
            property string terminal: "foot"
            property string taskManager: "plasma-systemmonitor --page-name Processes"
        }
        
        property JsonObject time: JsonObject {
            property string format: "HH:mm:ss"
            property string dateFormat: "dddd, MMMM dd, yyyy"
        }
    }
}
```

### 5. dots/hyprland/general.conf

Simplified Hyprland config without templates:

```conf
# General Hyprland configuration for illogical-impulse-quickshell

monitor=,preferred,auto,1

input {
    kb_layout = us
    numlock_by_default = true
    repeat_delay = 250
    repeat_rate = 35
    
    touchpad {
        natural_scroll = yes
        disable_while_typing = true
        clickfinger_behavior = true
    }
}

general {
    gaps_in = 6
    gaps_out = 10
    border_size = 2
    resize_on_border = true
    allow_tearing = false
}

decoration {
    rounding = 12
    blur {
        enabled = true
        xray = true
    }
}

gestures {
    workspace_swipe = true
}
```

### 6. dots/applications/foot.ini

Simplified foot config:

```ini
[main]
term=xterm-256color
login-shell=yes
app-id=foot

[scrollback]
lines=10000
multiplier=3.0

[cursor]
style=beam
blink=yes

[colors]
alpha=0.90
```

### 7. Updated default.nix

```nix
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  myWallpaperInit = pkgs.writeShellScriptBin "myWallpaperInit" ''
    hyprctl dispatch -- exec swww-daemon --format xrgb
    swww clear
    sleep 1
    swww img ~/Pictures/wallpapers/default.jpg --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
  '';
in {
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
      exec-once = ${myWallpaperInit}/bin/myWallpaperInit
      exec-once = ${pkgs.clipse}/bin/clipse -listen
      exec-once = ${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular
      
      source=~/.config/hypr/hyprland/general.conf
      source=~/.config/hypr/hyprland/env.conf
      source=~/.config/hypr/hyprland/rules.conf
      source=~/.config/hypr/hyprland/keybinds.conf
    '';
  };
}
```

## Benefits of This Approach

1. **Simplicity**: Direct file copying like `illogical-impulse`
2. **No complex templates**: Static configuration files
3. **Easy debugging**: Configuration files are directly editable
4. **Familiar pattern**: Follows your existing module structure
5. **Less dependencies**: Removes complex flake dependencies
6. **Maintainable**: Easy to understand and modify

## Migration Steps

1. Create the new file structure
2. Convert template-based configs to static files
3. Extract necessary configurations from the complex end-4-flakes system
4. Set up proper imports and package management
5. Create initialization script
6. Test the simplified implementation

This approach eliminates the complexity while maintaining all the functionality you need.