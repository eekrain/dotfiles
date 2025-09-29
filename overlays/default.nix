# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # Apply the wayland integration overlay directly
    # vscode = (import ./wayland-integration.nix final prev).vscode;
    # windsurf = (import ./wayland-integration.nix final prev).windsurf;
    # code-cursor = (import ./wayland-integration.nix final prev).code-cursor;
    # brave = (import ./wayland-integration.nix final prev).brave;
    # ungoogled-chromium = (import ./wayland-integration.nix final prev).ungoogled-chromium;
    # vesktop = (import ./wayland-integration.nix final prev).vesktop;
    # ferdium = (import ./wayland-integration.nix final prev).ferdium;
    # zoom-us = (import ./wayland-integration.nix final prev).zoom-us;
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.pkgs2311'
  packages-2411 = final: _prev: {
    pkgs2411 = import inputs.nixpkgs-2411 {
      system = final.system;
      config.allowUnfree = true;
    };
  };
  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.pkgs2411'
  packages-2405 = final: _prev: {
    pkgs2411 = import inputs.nixpkgs-2405 {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
