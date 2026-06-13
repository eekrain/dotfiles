# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: let
    # Pin Hyprland (and its matching portal) to nixos-26.05 so unstable
    # churn doesn't move it. Both must come from the same nixpkgs rev or the
    # version/IPC mismatch breaks Hyprland.
    pkgs2605 = import inputs.nixpkgs-2605 {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  in {
    hyprland = pkgs2605.hyprland;
    xdg-desktop-portal-hyprland = pkgs2605.xdg-desktop-portal-hyprland;
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.pkgs2311'
  packages-2505 = final: _prev: {
    pkgs2505 = import inputs.nixpkgs-2505 {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  packages-2411 = final: _prev: {
    pkgs2411 = import inputs.nixpkgs-2411 {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.pkgs2411'
  packages-2405 = final: _prev: {
    pkgs2411 = import inputs.nixpkgs-2405 {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
