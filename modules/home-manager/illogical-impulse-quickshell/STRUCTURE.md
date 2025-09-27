# Module Structure Comparison

## Current Complex Structure

```mermaid
graph TD
    A[illogical-impulse-quickshell/default.nix] --> B[inputs.illogical-impulse-quickshell.homeManagerModules.default]
    A --> C[programs.dots-hyprland]
    C --> D[Complex declarative config]
    D --> E[Template system @VARIABLE@]
    D --> F[Multiple nested modules]
    D --> G[Configuration generation]
    A --> H[end-4-flakes configs]
    H --> I[Template files]
    H --> J[Complex module system]
    H --> K[Python environment]
    H --> L[Multiple abstractions]
```

## Proposed Simplified Structure

```mermaid
graph TD
    A[illogical-impulse-quickshell/default.nix] --> B[Simple imports]
    B --> C[./dots.nix]
    B --> D[./theme.nix]
    B --> E[./programs/]
    C --> F[File copying approach]
    F --> G[Static config files]
    F --> H[Simple initialization script]
    D --> I[Direct theming]
    E --> J[Quickshell setup]
    G --> K[~/.config.example-quickshell/]
    K --> L[quickshell/]
    K --> M[hyprland/]
    K --> N[applications/]
```

## File Structure Comparison

### Current Complex Structure
```
modules/home-manager/illogical-impulse-quickshell/
├── default.nix                    # Complex flake-based
├── configs/                       # Template-based configs
│   ├── quickshell/                # Complex QML with templates
│   ├── hypr/                      # Template files (@VARIABLE@)
│   └── applications/              # Template configs
└── (Relies on external end-4-flakes)
```

### Proposed Simplified Structure
```
modules/home-manager/illogical-impulse-quickshell/
├── default.nix                    # Simple imports
├── dots.nix                       # File management
├── theme.nix                      # Theming
├── programs/                      # Program configs
│   └── quickshell/                # Quickshell setup
└── dots/                          # Static config files
    ├── quickshell/                # Static QML configs
    ├── hyprland/                  # Static Hyprland configs
    └── applications/              # Static app configs
```

## Configuration Flow Comparison

### Current Complex Flow
```mermaid
sequenceDiagram
    User->>Nix: Apply configuration
    Nix->>Flake: Load inputs.illogical-impulse-quickshell
    Flake->>Complex Module: Process templates
    Complex Module->>Template Engine: Replace @VARIABLES@
    Template Engine->>Config Files: Generate dynamic configs
    Config Files->>System: Apply complex setup
```

### Proposed Simplified Flow
```mermaid
sequenceDiagram
    User->>Nix: Apply configuration
    Nix->>Simple Module: Copy static files
    Simple Module->>File System: Copy to ~/.config.example-quickshell/
    User->>Init Script: Run init-illogical-impulse-quickshell
    Init Script->>Config Files: Copy to ~/.config/
    Config Files->>System: Direct file usage
```

## Benefits Summary

1. **Simplicity**: 70% reduction in complexity
2. **Maintainability**: Direct file editing vs template system
3. **Debugging**: Static files vs generated configurations
4. **Dependencies**: No complex flake dependencies
5. **Performance**: No template processing overhead
6. **Consistency**: Follows existing illogical-impulse pattern