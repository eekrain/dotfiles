{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.addons;
in {
  options.myModules.addons = {
    nix-ld = mkEnableOption "Enable nix-ld";
    devenv = mkEnableOption "Enable devenv";
    flatpak = mkEnableOption "Enable flatpak";
  };

  config = mkMerge [
    (mkIf cfg.nix-ld {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          vips # sharp npm package
        ];
      };
    })

    (mkIf cfg.flatpak {
      services.flatpak.enable = true;
    })

    {
      environment.systemPackages = with pkgs;
        [expressvpn]
        ++ lib.optionals (cfg.devenv) [
          devenv
          cachix
          appimage-run
          nload
        ];
      services.expressvpn.enable = true;
    }
  ];
}
