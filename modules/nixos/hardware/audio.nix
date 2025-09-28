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
    # Note: sound.enable is deprecated and removed - PipeWire handles ALSA integration
    services.pulseaudio.enable = false; # Disable legacy PulseAudio

    environment.systemPackages = with pkgs; [
      alsa-utils
      pavucontrol
    ];

    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # WirePlumber policy configuration for TWS headset support
      wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          # Critical fix: Define all required Bluetooth headset roles for profile switching
          "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];

          # Enable hardware volume control synchronization
          "bluez5.enable-hw-volume" = true;

          # --- Explicitly enable all high-quality codecs ---
          "bluez5.enable-sbc-xq" = true; # High-quality SBC
          "bluez5.enable-msbc" = true; # Improved call quality
          "bluez5.enable-aac" = true; # For Apple devices and others
          "bluez5.enable-aptx" = true; # Common high-quality codec
          "bluez5.enable-aptx-hd" = true; # Higher bitrate aptX
          "bluez5.enable-ldac" = true; # Sony's Hi-Res codec
        };
      };

      # Optional: Disable automatic profile switching if unstable
      # wireplumber.extraConfig."11-bluetooth-policy" = {
      #   "wireplumber.settings" = {
      #     "bluetooth.autoswitch-to-headset-profile" = false;
      #   };
      # };
    };
  };
}
