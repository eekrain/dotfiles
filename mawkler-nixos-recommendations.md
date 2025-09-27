# NixOS Configuration Optimization Recommendations

## Executive Summary

Based on the comprehensive analysis of your `mawkler-nixos` configuration, this document provides specific, actionable recommendations to optimize your Hyprland setup and Caelestia integration. The recommendations are prioritized by impact and implementation complexity.

## Priority 1: High Impact, Low Complexity

### 1.1 Hyprland Configuration Organization

**Current State**: Hyprland configuration is minimal and spread across multiple files.

**Recommendation**: Create a dedicated Hyprland configuration structure.

```nix
# Create: mawkler-nixos/home/hyprland/default.nix
{ pkgs, inputs, ... }: {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./rules.nix
    ./autostart.nix
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
  };
}
```

**Benefits**:
- Better organization and maintainability
- Easier to customize specific aspects
- Clear separation of concerns

### 1.2 Caelestia Performance Optimization

**Current State**: Transparency effects are enabled with moderate settings.

**Recommendation**: Add performance-oriented settings to Caelestia configuration.

```nix
# Modify: mawkler-nixos/home/caelestia.nix
programs.caelestia.settings = {
  # Existing settings...
  
  performance = {
    enable = true;
    animations = {
      enable = true;
      duration = 0.3;  # Reduced from current
    };
    transparency = {
      enabled = true;
      base = 0.7;      # Slightly less transparent
      layers = 0.5;    # Better layer separation
    };
  };
};
```

**Benefits**:
- Improved system responsiveness
- Better battery life on laptops
- Smoother animations

### 1.3 Systemd Service Optimization

**Current State**: Services are enabled but not optimized for Hyprland.

**Recommendation**: Optimize systemd services for Wayland/Hyprland.

```nix
# Add to: mawkler-nixos/home/default.nix
systemd.user = {
  services = {
    # Ensure services start after Hyprland
    hyprpaper.after = [ "graphical-session.target" ];
    hypridle.after = [ "graphical-session.target" ];
    
    # Optimize service timeouts
    clipse.serviceConfig.TimeoutStopSec = 5;
  };
};
```

**Benefits**:
- Faster login times
- Better service reliability
- Cleaner shutdown process

## Priority 2: Medium Impact, Medium Complexity

### 2.1 Hyprland Workspace Management

**Current State**: Basic workspace configuration without advanced rules.

**Recommendation**: Implement workspace-specific rules and layouts.

```nix
# Create: mawkler-nixos/home/hyprland/rules.nix
{ ... }: {
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "1,monitor:DP-1,default:true"
      "2,monitor:DP-1"
      "3,monitor:DP-1"
      "4,monitor:HDMI-A-1,default:true"
      "5,monitor:HDMI-A-1"
    ];
    
    windowrulev2 = [
      "float,class:(pavucontrol)"
      "float,class:(blueman-manager)"
      "workspace 2,class:(Brave-browser)"
      "workspace 3,class:(code)"
      "workspace 4,class:(Signal)"
    ];
  };
}
```

**Benefits**:
- Improved workflow efficiency
- Better multi-monitor support
- Consistent application placement

### 2.2 Caelestia Customization Enhancement

**Current State**: Caelestia uses default settings with minimal customization.

**Recommendation**: Enhance Caelestia with custom modules and behaviors.

```nix
# Modify: mawkler-nixos/home/caelestia.nix
programs.caelestia.settings = {
  # Existing settings...
  
  modules = {
    system-monitor = {
      enable = true;
      position = "right";
      showCpu = true;
      showMemory = true;
      showTemperature = true;
    };
    
    media-controls = {
      enable = true;
      position = "bottom";
      showAlbumArt = true;
    };
    
    quick-settings = {
      enable = true;
      position = "top";
      toggleWifi = true;
      toggleBluetooth = true;
      toggleDarkMode = true;
    };
  };
};
```

**Benefits**:
- Enhanced desktop functionality
- Better system monitoring
- Improved user experience

### 2.3 Theming System Enhancement

**Current State**: Stylix uses One Dark theme with basic configuration.

**Recommendation**: Enhance theming with custom schemes and better integration.

```nix
# Modify: mawkler-nixos/packages/stylix.nix
{ pkgs, inputs, ... }: {
  imports = [ inputs.stylix.nixosModules.stylix ];
  
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";
    polarity = "dark";
    
    # Enhanced cursor configuration
    cursor = {
      name = "Bibata-Modern-Classic";
      size = 24;
      package = pkgs.bibata-cursors;
    };
    
    # Font configuration
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.fira-code;
        name = "Fira Code Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.fira-code;
        name = "Fira Code Nerd Font";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono Nerd Font";
      };
    };
    
    # Target-specific theming
    targets = {
      hyprland.enable = true;
      gtk.enable = true;
      qt.enable = true;
    };
  };
}
```

**Benefits**:
- More cohesive visual experience
- Better font rendering
- Improved cursor experience

## Priority 3: High Impact, High Complexity

### 3.1 Hyprland Security Hardening

**Current State**: Basic security configuration without specific Hyprland hardening.

**Recommendation**: Implement security-focused Hyprland configuration.

```nix
# Create: mawkler-nixos/home/hyprland/security.nix
{ ... }: {
  wayland.windowManager.hyprland.settings = {
    # Security-focused settings
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      force_default_wallpaper = 0;
      vfr = true;  # Variable frame rate for security
    };
    
    # Input security
    input = {
      kb_layout = "se";
      kb_variant = "";
      kb_model = "";
      kb_options = "";
      kb_rules = "";
      
      follow_mouse = 1;
      mouse_refocus = false;
      sensitivity = 0;
      accel_profile = "flat";
    };
    
    # Window security rules
    windowrulev2 = [
      "noblur,class:(.*),title:(.*password.*)"
      "noblur,class:(.*),title:(.*login.*)"
      "nofocus,class:(.*),title:(.*update.*)"
      "float,class:(.*),title:(.*authentication.*)"
    ];
  };
}
```

**Benefits**:
- Enhanced system security
- Better input handling
- Improved privacy

### 3.2 Caelestia Backup and Recovery System

**Current State**: No automated backup system for Caelestia configurations.

**Recommendation**: Implement backup and recovery system for desktop configurations.

```nix
# Create: mawkler-nixos/home/caelestia/backup.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    restic
    (writeShellScriptBin "caelestia-backup" ''
      #!/bin/sh
      restic backup \
        --tag caelestia-config \
        --exclude-file ~/.config/caelestia/backup-exclude.txt \
        ~/.config/caelestia/
    '')
    (writeShellScriptBin "caelestia-restore" ''
      #!/bin/sh
      restic restore latest \
        --target ~/.config/caelestia/ \
        --tag caelestia-config
    '')
  ];
  
  # Systemd timer for automatic backups
  systemd.user = {
    timers.caelestia-backup = {
      Unit.Description = "Caelestia configuration backup";
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
    
    services.caelestia-backup = {
      Unit.Description = "Caelestia configuration backup";
      Service = {
        ExecStart = "${pkgs.restic}/bin/restic backup ~/.config/caelestia/";
        Type = "oneshot";
      };
    };
  };
}
```

**Benefits**:
- Automated configuration backup
- Easy recovery from configuration errors
- Version control for desktop settings

### 3.3 Performance Monitoring and Optimization

**Current State**: Basic system monitoring without desktop-specific metrics.

**Recommendation**: Implement comprehensive performance monitoring for Hyprland and Caelestia.

```nix
# Create: mawkler-nixos/home/performance.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    btop
    nvtop
    iotop
    (writeShellScriptBin "hyprland-monitor" ''
      #!/bin/sh
      while true; do
        echo "=== Hyprland Performance ==="
        echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
        echo "Memory Usage: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
        echo "GPU Usage: $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo 'N/A')%"
        echo "Active Windows: $(hyprctl clients | grep -c 'class:')"
        echo "Running Processes: $(ps aux | wc -l)"
        sleep 5
      done
    '')
  ];
  
  # Systemd service for monitoring
  systemd.user.services.hyprland-monitor = {
    Unit.Description = "Hyprland performance monitor";
    Install.WantedBy = [ "hyprland-session.target" ];
    Service = {
      ExecStart = "${pkgs.btop}/bin/btop";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
```

**Benefits**:
- Real-time performance monitoring
- Proactive issue detection
- Better resource management

## Implementation Plan

### Phase 1: Quick Wins (Week 1)
1. Implement Hyprland configuration organization
2. Optimize Caelestia performance settings
3. Enhance systemd service configuration

### Phase 2: Enhanced Functionality (Week 2-3)
1. Implement workspace management rules
2. Enhance Caelestia with custom modules
3. Improve theming system integration

### Phase 3: Advanced Features (Week 4-6)
1. Implement security hardening
2. Set up backup and recovery system
3. Deploy performance monitoring

## Testing and Validation

### Testing Strategy
1. **Unit Testing**: Test each configuration change individually
2. **Integration Testing**: Verify components work together
3. **Performance Testing**: Measure impact on system resources
4. **User Experience Testing**: Validate workflow improvements

### Validation Metrics
- System boot time
- Application launch time
- Memory usage
- CPU utilization
- Battery life (for laptops)
- User satisfaction

## Risk Assessment

### Low Risk
- Configuration organization changes
- Theming enhancements
- Service optimization

### Medium Risk
- Workspace rule changes
- Caelestia module additions
- Performance monitoring setup

### High Risk
- Security hardening changes
- Backup system implementation
- Major architectural changes

## Conclusion

These recommendations provide a comprehensive roadmap for optimizing your NixOS configuration with a focus on Hyprland and Caelestia integration. The phased approach ensures manageable implementation while minimizing risk. Each recommendation is designed to improve either performance, security, or user experience while maintaining the flexibility and reproducibility that NixOS provides.

The key to success is implementing changes incrementally, testing thoroughly, and maintaining backups throughout the process. This approach will result in a more robust, efficient, and enjoyable desktop environment.