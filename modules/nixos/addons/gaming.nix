{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.myModules.addons;
in
{
  options.myModules.addons = {
    gaming = mkEnableOption "Enable Steam and gaming tooling";
  };

  config = mkIf cfg.gaming {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      gamescope
      (makeDesktopItem {
        name = "steam-nvidia";
        desktopName = "Steam (NVIDIA)";
        exec = "prefer-nvidia steam";
        icon = "steam";
        terminal = false;
        categories = [ "Game" ];
      })
    ];
  };
}
