{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
in {
  options.myModules.hardware.audio = mkEnableOption "Enable custom audio settings";

  config = mkIf cfg.audio {
    environment.systemPackages = with pkgs; [
      psmisc
      lsof
      pulseaudioFull
    ];

    sound.enable = lib.mkForce false;
    hardware.pulseaudio.enable = false;
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
  };
}
