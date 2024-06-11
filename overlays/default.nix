# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.pkgs2405'
  packages-2405 = final: _prev: {
    pkgs2405 = import inputs.nixpkgs-2405 {
      system = final.system;
      config.allowUnfree = true;
    };
  };
  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.pkgs2311'
  packages-2311 = final: _prev: {
    pkgs2311 = import inputs.nixpkgs-2311 {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
