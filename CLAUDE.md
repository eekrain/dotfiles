# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS dotfiles repository featuring a Hyprland desktop environment with the "illogical-impulse" rice theme. It uses Nix flakes for system configuration and home-manager for user-specific settings.

## Key Commands

### System Management
- `sudo nixos-rebuild switch --flake .#hostname` - Apply system configuration
- `home-manager switch --flake .#username@hostname` - Apply user configuration
- `init-illogical-impulse` - Initialize AGS configuration (required after each update)
- `nix develop` - Enter development shell with flake-enabled nix
- `nix fmt` - Format Nix files using alejandra

### Development
- `nvfetcher` - Update package sources in `pkgs/_sources/`
- `nix build .#hostname` - Build system configuration
- `nix shell` - Legacy shell access

## Architecture

### Core Structure
- `flake.nix` - Main flake configuration with system inputs and outputs
- `nixos/` - System-level configurations (one directory per hostname)
- `home-manager/` - User-specific configurations (one file per username)
- `modules/` - Reusable NixOS and home-manager modules
- `pkgs/` - Custom package definitions
- `overlays/` - Package overlays and modifications

### Module Organization
- `modules/nixos/` - System modules (desktop, hardware, networking)
- `modules/home-manager/` - Home modules (CLI tools, programs, themes)
- `modules/home-manager/illogical-impulse/` - AGS-based desktop environment

### Special Components
**illogical-impulse Desktop Environment:**
- Uses AGS (Aylur's Gtk Shell) for desktop widgets
- Manual configuration initialization required via `init-illogical-impulse` script
- Located in `modules/home-manager/illogical-impulse/dots/`
- Includes custom Hyprland configuration, AGS modules, and theming

**Package Management:**
- Custom packages in `pkgs/` directory
- Sources managed by nvfetcher (`pkgs/nvfetcher.toml`)
- Overlays provide access to stable nixpkgs versions via `pkgs.pkgs2411`

### Configuration Pattern
1. System configurations in `nixos/hostname/` reference user configurations
2. User configurations in `home-manager/username.nix` import modules
3. Modules provide reusable functionality across machines/users
4. Custom packages and overlays extend base nixpkgs

### Important Notes
- The illogical-impulse theme requires manual AGS configuration updates
- Wallpaper initialization uses a custom script for GIF support
- System uses multiple nixpkgs channels (unstable, 24.11, 24.05)
- Custom binary caches configured for faster builds
- Hyprland configuration is split across multiple files in the dots directory