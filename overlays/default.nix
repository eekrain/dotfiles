# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # When applied, the nixos-26.05 nixpkgs set (declared in the flake inputs)
  # will be accessible through 'pkgs.pkgs2605'
  packages-2605 = final: _prev: {
    pkgs2605 = import inputs.nixpkgs-2605 {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
