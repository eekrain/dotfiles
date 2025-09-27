# Project Knowledge: NixOS Flake Configuration System

## Overview

This is a comprehensive NixOS flake configuration system that manages both system-level (NixOS) and user-level (Home Manager) configurations. The system is designed to be modular, maintainable, and extensible, with a focus on providing a complete desktop environment experience.

## System Architecture

### Core Components

1. **Flake Entry Point** (`flake.nix`)
   - Defines all inputs (dependencies)
   - Configures outputs (packages, modules, configurations)
   - Sets up caching with multiple binary caches
   - Supports multiple systems (x86_64-linux, aarch64-linux, etc.)

2. **Module System**
   - **NixOS Modules** (`modules/nixos/`): System-level configurations
   - **Home Manager Modules** (`modules/home-manager/`): User-level configurations
   - **Overlays** (`overlays/`): Package modifications and additions

3. **Configuration Outputs**
   - **NixOS Configurations** (`nixosConfigurations`): Complete system configurations
   - **Home Manager Configurations** (`homeConfigurations`): User environment configurations

## Directory Structure

```
/home/eekrain/dotfiles/
├── flake.nix                    # Main flake definition
├── flake.lock                   # Locked dependencies
├── home-manager/                 # Home Manager user configurations
│   └── eekrain.nix              # Main user configuration
├── modules/                      # Reusable modules
│   ├── home-manager/            # Home Manager modules
│   │   ├── default-settings.nix # Default HM settings
│   │   ├── cli/                  # CLI tools configuration
│   │   ├── programs/             # Program-specific configs
│   │   ├── addons/              # Additional packages and settings
│   │   └── illogical-impulse-quickshell/ # Quickshell desktop environment
│   └── nixos/                   # NixOS system modules
│       ├── default-settings.nix # Default NixOS settings
│       ├── desktop/             # Desktop environment configs
│       ├── hardware/            # Hardware-specific configurations
│       ├── networking/          # Network configurations
│       └── addons/              # Additional system packages
├── nixos/                       # Host-specific NixOS configurations
│   └── vivobook-15/            # Configuration for vivobook-15 host
│       ├── configuration.nix   # Main system configuration
│       ├── hardware-configuration.nix # Hardware detection
│       └── bootloader.nix       # Boot loader configuration
├── overlays/                    # Package overlays
│   └── default.nix             # Overlay definitions
├── pkgs/                        # Custom packages
│   ├── default.nix             # Package definitions
│   ├── my-custom-font.nix     # Custom font package
│   ├── my-icons/              # Custom icon set
│   └── hiddify/               # Hiddify VPN client
└── end-4-dots/                 # Original end-4 dotfiles (reference)
    └── ...                    # Hyprland configurations and scripts
```

## Key Features and Modules

### 1. Home Manager Modules

#### Default Settings (`modules/home-manager/default-settings.nix`)
- Enables Home Manager
- Configures nixpkgs overlays and settings
- Sets up user directories

#### CLI Tools (`modules/home-manager/cli/`)
- **Git**: Version control configuration
- **IDE**: Development environment setup
- **Kitty**: Terminal emulator configuration
- **Zsh**: Shell configuration with Starship prompt

#### Programs (`modules/home-manager/programs/`)
- **bat**: Cat alternative with syntax highlighting
- **browser**: Web browser configuration
- **btop**: System monitor
- **easyeffect-audio**: Audio effects
- **hypridle**: Idle management
- **hyprlock**: Screen locking
- **mimeapps**: File type associations
- **motrix**: Download manager
- **mpv**: Media player with shaders
- **vscode**: Code editor
- **wofi**: Application launcher

#### Addons (`modules/home-manager/addons/`)
- Additional packages (OBS Studio, LibreOffice, etc.)
- Wallpaper collection
- Development tools (Node.js, Bun)

#### illogical-impulse-quickshell (`modules/home-manager/illogical-impulse-quickshell/`)
- **Quickshell**: Qt-based widget system for desktop shell
- **Hyprland**: Wayland compositor configuration
- **UWSM Integration**: Universal Wayland Session Manager
- **Material You Theming**: Dynamic color generation
- **AI Integration**: Gemini and Ollama support
- **Comprehensive Widgets**: Bar, sidebars, dock, overview, etc.

### 2. NixOS Modules

#### Default Settings (`modules/nixos/default-settings.nix`)
- Nix settings with experimental features
- Binary cache configuration
- Home Manager integration
- Zsh and direnv setup
- Security configuration (doas)

#### Desktop (`modules/nixos/desktop/`)
- **Hyprland**: Wayland compositor
- **Nautilus**: File manager
- **SDDM/Greetd**: Display managers

#### Hardware (`modules/nixos/hardware/`)
- **Audio**: PipeWire and PulseAudio configuration
- **Bluetooth**: Bluetooth support
- **GPU**: Graphics driver configuration (AMD, NVIDIA, hybrid)
- **Power Management**: Power saving features
- **Suspend-to-Hibernate**: Power management

#### Networking (`modules/nixos/networking/`)
- NetworkManager configuration
- Firewall settings
- Cloudflare Warp integration
- Clash proxy support
- Redsocks configuration

#### Addons (`modules/nixos/addons/`)
- **Virtualization**: Docker, VirtualBox, Waydroid
- **Development**: nix-ld, devenv
- **Android**: ADB support
- **Flatpak**: Flatpak support

### 3. Custom Packages (`pkgs/`)

- **my-custom-font**: Custom font packaging
- **my-icons**: Custom icon sets
- **hiddify**: VPN client
- **waybar-mpris**: Waybar MPRIS extension
- **sddm-sugar-candy**: SDDM theme
- **responsivelyapp**: Responsive web design tool

### 4. Overlays (`overlays/`)

- **additions**: Custom packages
- **modifications**: Package modifications
- **packages-2411/packages-2405**: Access to stable nixpkgs

## Special Features

### 1. illogical-impulse-quickshell Module

This is a comprehensive desktop environment module based on end-4's Hyprland dotfiles:

#### Key Components:
- **Quickshell**: Qt-based widget system replacing traditional bars
- **Hyprland**: Wayland compositor with advanced features
- **UWSM Integration**: Proper session management
- **Material You Theming**: Dynamic color generation from wallpaper
- **AI Integration**: Support for Gemini API and Ollama models
- **Comprehensive Widget System**:
  - Bar with workspaces, system tray, clock
  - Sidebars with AI chat, translator, anime viewer
  - Dock with application launcher
  - Overview with live previews
  - Notification popups
  - Media controls
  - Screen corners
  - Lock screen
  - Wallpaper selector

#### UWSM (Universal Wayland Session Manager) Integration:
- Proper session management with systemd
- Environment variables managed through UWSM
- Service dependencies correctly configured
- Automatic startup of Quickshell with Hyprland

#### Initialization Script:
- `init-illogical-impulse-quickshell` script for setting up dotfiles
- Copies configuration files to appropriate locations
- Sets proper permissions
- Configures environment variables

### 2. Multi-GPU Support

The system includes special support for multiple GPU configurations:
- Default AMD GPU configuration
- Specialization for NVIDIA GPU
- Hybrid AMD+NVIDIA configuration
- Proper driver loading and configuration

### 3. Development Environment

The flake includes a comprehensive development environment:
- Multiple programming languages (Node.js, Bun, Python)
- Development tools (VSCode, Git)
- Container support (Docker)
- Virtual environment support

## Configuration Usage

### Home Manager Configuration

In `home-manager/eekrain.nix`:

```nix
{
  imports = [
    outputs.homeManagerModules.default-settings
    outputs.homeManagerModules.cli
    outputs.homeManagerModules.programs
    outputs.homeManagerModules.addons
    outputs.homeManagerModules.illogical-impulse-quickshell
  ];

  myHmModules = {
    cli = {
      git = true;
      ide = true;
      zsh = true;
    };

    programs = {
      bat = true;
      browser = true;
      # ... other programs
    };

    addons.enable = true;
  };
}
```

### NixOS Configuration

In `nixos/vivobook-15/configuration.nix`:

```nix
{
  imports = [
    outputs.nixosModules.default-settings
    outputs.nixosModules.hardware
    outputs.nixosModules.desktop
    outputs.nixosModules.networking
    outputs.nixosModules.addons
  ];

  myModules = {
    hardware = {
      audio = true;
      bluetooth = true;
      gpu = "amd"; # or "nvidia" or "amd+nvidia"
      # ... other hardware settings
    };

    desktop = {
      hyprland.enable = true;
      # ... other desktop settings
    };

    # ... other module settings
  };
}
```

## Flake Inputs and Dependencies

### Core Inputs:
- **nixpkgs**: Unstable and stable versions (24.11, 24.05)
- **home-manager**: User environment management
- **nixos-hardware**: Hardware-specific configurations
- **chaotic**: Chaotic-Nyx package repository

### Desktop Environment Inputs:
- **hyprland**: Wayland compositor
- **hyprcursor-phinger**: Cursor theme
- **ags**: Widget system (for reference)

### Application Inputs:
- **auto-cpufreq**: CPU frequency scaling
- **zen-browser**: Web browser
- **grub2-themes**: GRUB themes

### Binary Caches:
The system is configured with multiple binary caches for faster builds:
- cache.nixos.org
- nix-community.cachix.org
- hyprland.cachix.org
- nixpkgs-wayland.cachix.org
- nrdxp.cachix.org
- nix-gaming.cachix.org
- anyrun.cachix.org
- nyx.chaotic.cx

## Build and Deployment

### Building the Configuration:

```bash
# Build NixOS system configuration
nixos-rebuild switch --flake .#eka-laptop

# Build Home Manager user configuration
home-manager switch --flake .#eekrain@eka-laptop

# Build both (using nh helper)
nh os switch
nh home switch
```

### Development Environment:

```bash
# Enter development shell
nix develop

# Format Nix files
nix fmt

# Build custom packages
nix build .#my-custom-font
```

## Special Considerations

### 1. UWSM Integration

The illogical-impulse-quickshell module uses UWSM for proper session management:
- Environment variables are managed through UWSM files
- Systemd services are properly configured with dependencies
- Home Manager systemd integration is disabled when using UWSM

### 2. Quickshell Configuration

Quickshell configurations are copied to the user's home directory:
- Files are stored in `~/.config.example-quickshell/`
- Initialization script copies them to `~/.config/`
- This allows Quickshell to have write access to its configuration

### 3. Multi-Version Package Support

The system supports accessing packages from multiple nixpkgs versions:
- Current unstable (default)
- 24.11 stable
- 24.05 stable
- Available through overlays as `pkgs2411` and `pkgs2405`

## Troubleshooting

### Common Issues:

1. **Quickshell not starting**:
   - Check UWSM environment variables
   - Verify systemd service status
   - Run initialization script

2. **GPU issues**:
   - Check GPU configuration in NixOS settings
   - Verify specializations are correctly applied
   - Check driver loading

3. **Package conflicts**:
   - Check overlay priorities
   - Verify package versions
   - Check for conflicting module options

### Debug Commands:

```bash
# Check systemd service status
systemctl --user status quickshell

# Check UWSM environment
cat ~/.config/uwsm/env

# Verify Quickshell configuration
ls -la ~/.config/quickshell/

# Check Hyprland configuration
hyprctl config
```

## Future Enhancements

The system is designed to be extensible:
- Additional desktop environment modules
- More hardware-specific configurations
- Expanded development tools
- Additional custom packages
- Enhanced theming options

This comprehensive flake system provides a complete, maintainable, and extensible NixOS configuration with a focus on providing an excellent desktop environment experience.