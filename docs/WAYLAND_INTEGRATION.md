# Wayland Integration for Chromium-based Applications

This document explains the implementation of native Wayland integration for Chromium-based applications in this NixOS configuration.

## Overview

Chromium-based applications (VSCode, Chrome, Brave, etc.) often experience UI scaling issues in Wayland environments due to running through XWayland compatibility layer. This implementation provides a clean, declarative solution that forces native Wayland rendering with proper scaling and integration.

## Problem Analysis

### Root Cause

- Applications running through XWayland are unaware of display scaling factors
- They render at base resolution, then the compositor scales the bitmap (causing blurriness)
- Native Wayland applications communicate directly with the compositor for proper scaling

### Previous Solutions (Now Deprecated)

- `NIXOS_OZONE_WL` environment variable (injects deprecated flags)
- `ELECTRON_OZONE_PLATFORM_HINT` environment variable (removed in Electron 38+)
- Manual `.desktop` file editing (fragile and not declarative)

## Implementation

### Architecture

We use Home Manager with `xdg.desktopEntries` to create overriding desktop entries that launch applications with the correct Wayland flags. This approach:

1. **Uses binary cache** - installs original packages without rebuilding
2. **Creates desktop entries** - overrides system `.desktop` files in `~/.local/share/applications/`
3. **Applies Wayland flags** - ensures native Wayland rendering with proper scaling
4. **Declarative** - fully managed through Nix configuration

### Critical Wayland Flags

```nix
waylandFlags = [
  "--ozone-platform=wayland"                                    # Force Wayland backend
  "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer,UseOzonePlatform"  # Enable Wayland features
  "--gtk-version=4"                                             # Use GTK4 for better integration
  "--enable-wayland-ime"                                        # Enable Input Method Editor support
  "--disable-features=UseChromeOSDirectVideoDecoder,WaylandFractionalScaleV1"  # Fix scaling issues
];
```

### Key Fix: WaylandFractionalScaleV1

The `--disable-features=WaylandFractionalScaleV1` flag is critical for resolving scaling blurriness on Hyprland and other Wayland compositors. This feature was causing scaling issues in recent Chromium versions.

## Supported Applications

The implementation supports the following Chromium-based applications:

| Application        | Package Name         | Desktop Entry        | Notes                       |
| ------------------ | -------------------- | -------------------- | --------------------------- |
| Visual Studio Code | `vscode`             | `code`               | Official Microsoft build    |
| Windsurf           | `windsurf`           | `windsurf`           | AI-powered code editor      |
| Cursor             | `code-cursor`        | `code-cursor`        | AI-powered code editor      |
| Brave Browser      | `brave`              | `brave-browser`      | Privacy-focused browser     |
| Ungoogled Chromium | `ungoogled-chromium` | `ungoogled-chromium` | Privacy-enhanced Chromium   |
| Vesktop            | `vesktop`            | `vesktop`            | Discord client with Vencord |
| Ferdium            | `ferdium`            | `ferdium`            | Messaging application       |
| Zoom               | `zoom-us`            | `zoom`               | Video conferencing          |

## Usage

### Enabling the Module

In your `home-manager/eekrain.nix`:

```nix
{
  # Import the module
  imports = [
    outputs.homeManagerModules.wayland-integration
  ];

  # Enable Wayland integration
  myHmModules.waylandIntegration.enable = true;
}
```

### Adding New Applications

To add a new Chromium-based application:

1. Add the package to `home.packages` in [`modules/home-manager/wayland-integration.nix`](modules/home-manager/wayland-integration.nix)
2. Create a corresponding `xdg.desktopEntries` entry with the Wayland flags
3. Rebuild your Home Manager configuration

Example for a new application:

```nix
# Add to home.packages
new-chromium-app

# Add to xdg.desktopEntries
"new-app" = {
  name = "New App";
  genericName = "Application Type";
  comment = "Application description";
  exec = "new-app ${waylandFlagsStr} %U";  # Important: Add flags here
  icon = "new-app";
  type = "Application";
  terminal = false;
  categories = [ "Category" ];
  startupNotify = true;
  startupWMClass = "NewApp";
};
```

## Performance Benefits

### Binary Cache Utilization

- **No rebuilding** of large packages (Chromium, VSCode, etc.)
- **Instant builds** - only creates tiny desktop entry files
- **Faster updates** - `home-manager switch` completes in seconds

### Comparison with Overlay Method

| Method           | Build Time | Binary Cache | Maintenance |
| ---------------- | ---------- | ------------ | ----------- |
| Package Override | Hours      | No           | Complex     |
| Desktop Entries  | Seconds    | Yes          | Simple      |

## Troubleshooting

### Verify Wayland is Working

1. Check if application is using Wayland:

   ```bash
   grep -i wayland /proc/$(pidof code)/environ
   ```

2. Look for Wayland-specific logs:
   ```bash
   journalctl -f | grep -i wayland
   ```

### Common Issues

#### Blurry Text Still Present

- Ensure `WaylandFractionalScaleV1` is disabled in flags
- Check if compositor supports fractional scaling
- Try clearing GPU cache: `rm -rf ~/.config/Code/GPUCache`

#### Application Won't Start

- Verify the executable name matches the desktop entry
- Check if the package is installed in `home.packages`
- Test manual launch: `code --ozone-platform=wayland`

#### Missing Window Decorations

- Ensure `WaylandWindowDecorations` is enabled in flags
- Check compositor configuration for client-side decorations

### NVIDIA-Specific Issues

For NVIDIA users, add these environment variables to your system configuration:

```nix
# In configuration.nix
environment.variables = {
  LIBVA_DRIVER_NAME = "nvidia";
  XDG_SESSION_TYPE = "wayland";
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
};
```

## Advanced Configuration

### Custom Flags

To customize the Wayland flags for specific applications, modify the `waylandFlags` list in [`modules/home-manager/wayland-integration.nix`](modules/home-manager/wayland-integration.nix):

```nix
# Add custom flags
waylandFlags = [
  # Standard flags...
  "--custom-flag=value"  # Your custom flag
];
```

### Per-Application Flags

For application-specific flags, create separate flag variables:

```nix
let
  standardFlags = [ /* ... */ ];
  vscodeFlags = standardFlags ++ [ "--vscode-specific-flag" ];
in {
  xdg.desktopEntries = {
    "code" = {
      exec = "code ${builtins.concatStringsSep " " vscodeFlags} %F";
      # ...
    };
  };
}
```

## Future Considerations

### Upstream Changes

The Wayland ecosystem is rapidly evolving. This implementation is designed to be:

- **Flexible** - easy to update flags as upstream changes
- **Explicit** - no reliance on deprecated environment variables
- **Transparent** - clear visibility of all applied flags

### Monitoring for Deprecations

To stay current with upstream changes:

1. Monitor Chromium/Electron release notes
2. Test applications after major updates
3. Update flags as new features become stable

## References

- [Chromium Ozone Platform Documentation](https://chromium.googlesource.com/chromium/src/+/HEAD/ui/ozone/)
- [Electron Wayland Support](https://www.electronjs.org/docs/latest/tutorial/wayland-support)
- [Hyprland Wayland Integration](https://wiki.hyprland.org/Useful-Utilities/Wayland-troubleshooting/)
- [NixOS Home Manager Desktop Entries](https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.desktopEntries)

## Conclusion

This implementation provides a robust, performant, and maintainable solution for Wayland integration of Chromium-based applications. By using Home Manager desktop entries, we achieve:

- **Native Wayland rendering** with proper scaling
- **Binary cache utilization** for fast builds
- **Declarative configuration** following NixOS principles
- **Easy maintenance** and extensibility

The solution addresses the root cause of scaling issues while providing the best possible user experience in Wayland environments.
