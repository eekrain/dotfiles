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
    # 1. Establish a clean audio server baseline.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # 2. Configure the Bluetooth service.
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true; # For battery reporting and other features.
        };
      };
    };

    # 3. Fine-tune WirePlumber policy for stability and quality.
    services.pipewire.wireplumber.extraConfig."51-bluez-policy" = {
      # Ensure all high-quality codecs are explicitly enabled.
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-aac" = true;
        "bluez5.enable-aptx" = true;
        "bluez5.enable-aptx-hd" = true;
        "bluez5.enable-ldac" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
      };
      # Prioritize A2DP sink on connection to avoid getting stuck in HSP/HFP.
      "monitor.bluez.rules" = [
        {
          matches = [{"device.name" = "~bluez_card.*";}];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = ["a2dp_sink" "hsp_hs" "hfp_hf"];
            };
          };
        }
      ];
      # Prevent applications from automatically forcing a switch to headset mode.
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };

    # 4. Install essential diagnostic and management tools.
    environment.systemPackages = with pkgs; [
      alsa-utils
      pavucontrol
      blueman
      pulseaudio # For PulseAudio compatibility tools including pactl
      pipewire
      wireplumber
      bluez
      # SBC codec library with XQ support
      sbc
      # Include the verification script
      (writeScriptBin "verify-bluetooth-audio" (builtins.readFile ./verify-bluetooth-audio.sh))
    ];
  };
}
