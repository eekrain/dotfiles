# Fixing Bluetooth High-Fidelity Audio Issues on NixOS

## The Problem: Your Bluetooth Headphones Sound Like a Telephone

You've just paired your expensive Bluetooth headphones with your NixOS system, but instead of the rich, high-quality audio you expected, everything sounds muffled and mono—like a telephone call. You check your audio settings and find that your device is stuck in "Headset Head Unit (HSP/HFP)" mode instead of the high-quality "High Fidelity Playback (A2DP)" mode.

If this sounds familiar, you're not alone. This is a common issue on NixOS with PipeWire, and the good news is that it's completely fixable.

## Understanding Why This Happens

The issue isn't that your headphones don't support high-quality audio—they almost certainly do. The problem is in how NixOS manages the complex negotiation between your system and your Bluetooth device.

Here's what's happening behind the scenes:

1. **Your headphones connect successfully** to your system via Bluetooth
2. **The system tries to establish an audio profile**—either high-quality A2DP for music or basic HSP/HFP for calls
3. **Something goes wrong in the negotiation**, and your system falls back to the basic call quality profile
4. **You're stuck with low-quality audio** until you manually fix it

The root cause is typically not missing software or incompatible hardware, but rather a **policy management issue** in how PipeWire and WirePlumber (the audio session managers) handle Bluetooth device connections.

## The Solution: A Step-by-Step Guide

Follow these steps to fix your Bluetooth audio quality issues on NixOS.

### Step 1: Create a Clean Audio Configuration

First, we need to ensure your system is using PipeWire as the sole audio server without any conflicts.

Add this to your `/etc/nixos/configuration.nix`:

```nix
# Disable legacy audio systems to prevent conflicts
services.pulseaudio.enable = false;

# Enable Real-Time Kit for low-latency audio processing
security.rtkit.enable = true;

# Enable PipeWire with all compatibility layers
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;  # For PulseAudio compatibility
  jack.enable = true;   # For professional audio applications
};
```

**Why we're doing this:** By explicitly disabling PulseAudio and enabling PipeWire with all its compatibility layers, we ensure there's only one audio server managing your system. This eliminates conflicts that can prevent proper Bluetooth audio negotiation.

### Step 2: Configure Bluetooth Service for Optimal Performance

Next, we need to configure the Bluetooth service itself:

```nix
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;  # Ensure Bluetooth is ready at startup
  settings = {
    General = {
      Experimental = true;  # Enable additional features like battery reporting
    };
  };
};
```

**Why we're doing this:** The `powerOnBoot = true` ensures your Bluetooth adapter is active immediately when your system starts, preventing timing issues during device connection. The `Experimental = true` setting enables additional Bluetooth features that can improve compatibility with modern devices.

### Step 3: The Critical Fix - WirePlumber Policy Configuration

This is the most important part of the solution. We need to tell WirePlumber (the session manager) exactly how to handle your Bluetooth devices.

Add this configuration:

```nix
services.pipewire.wireplumber.extraConfig."51-bluez-policy" = {
  # Enable all high-quality audio codecs
  "monitor.bluez.properties" = {
    "bluez5.enable-sbc-xq" = true;    # Enhanced SBC quality
    "bluez5.enable-aac" = true;        # Apple's codec
    "bluez5.enable-aptx" = true;       # Qualcomm's codec
    "bluez5.enable-aptx-hd" = true;    # High-quality aptX
    "bluez5.enable-ldac" = true;       # Sony's Hi-Res codec
    "bluez5.enable-msbc" = true;      # Better call quality
    "bluez5.enable-hw-volume" = true;  # Hardware volume control
  };

  # Prioritize high-quality audio profile on connection
  "monitor.bluez.rules" = [
    {
      matches = [ { "device.name" = "~bluez_card.*"; } ];
      actions = {
        "update-props" = {
          # Try high-quality A2DP first, then fallback to call profiles
          "bluez5.reconnect-profiles" = [ "a2dp_sink" "hsp_hs" "hfp_hf" ];
        };
      };
    }
  ];

  # Prevent automatic switching to call quality
  "wireplumber.settings" = {
    "bluetooth.autoswitch-to-headset-profile" = false;
  };
};
```

**Why we're doing this:** This configuration addresses three critical issues:

1. **Explicit Codec Enablement**: We're telling WirePlumber to enable all high-quality audio codecs during negotiation. Without this, it might only negotiate the basic SBC codec.

2. **Profile Prioritization**: By setting `"bluez5.reconnect-profiles" = [ "a2dp_sink" "hsp_hs" "hfp_hf" ]`, we're telling the system to always try the high-quality A2DP profile first, rather than getting stuck in the basic HSP/HFP profile.

3. **Preventing Unwanted Switching**: The `"bluetooth.autoswitch-to-headset-profile" = false` setting prevents background applications (like web browsers or messaging apps) from automatically switching your headphones to call quality when they request microphone access.

### Step 4: Install Useful Audio Tools

Add these packages to your system:

```nix
environment.systemPackages = with pkgs; [
  pavucontrol    # GUI for managing audio devices and profiles
  blueman        # Advanced Bluetooth manager
  pipewire       # Core audio server
  wireplumber    # Session manager
  bluez          # Bluetooth tools
];
```

**Why we're doing this:** These tools provide essential functionality for managing and troubleshooting your audio setup. `pavucontrol` is particularly important as it allows you to visually confirm which profile and codec your headphones are using.

### Step 5: Apply Configuration and Reset Your Device

Now apply your configuration changes:

```bash
sudo nixos-rebuild switch
```

After the rebuild, **completely remove and re-pair your Bluetooth device**. This is a critical step:

```bash
# Start the Bluetooth control tool
bluetoothctl

# Replace with your device's MAC address
[bluetooth]# disconnect 70:5A:6F:69:56:88
[bluetooth]# remove 70:5A:6F:69:56:88
[bluetooth]# scan on
# Wait for your device to appear, then:
[bluetooth]# pair 70:5A:6F:69:56:88
[bluetooth]# trust 70:5A:6F:69:56:88
[bluetooth]# connect 70:5A:6F:69:56:88
```

**Why we're doing this:** Bluetooth maintains a cache of device capabilities that can become corrupted. By completely removing and re-pairing your device, we force the system to perform a fresh discovery of your device's capabilities, including its support for high-quality audio profiles.

### Step 6: Verify the Fix

Check that your headphones are now using the high-quality profile:

```bash
# Check the active profile and codec
pactl list sinks | grep -A 5 "bluez_output"
```

You should see output like:

```
Active Profile: a2dp_sink
bluetooth.codec = "SBC-XQ"
```

Alternatively, open `pavucontrol`, go to the "Configuration" tab, and verify that your headphones are set to "High Fidelity Playback (A2DP Sink)".

## Complete Configuration File

For convenience, here's the complete configuration you can add to your `configuration.nix`:

```nix
{ pkgs, ... }:

{
  # Step 1: Clean audio configuration
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Step 2: Bluetooth service configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # Step 3: WirePlumber policy configuration
  services.pipewire.wireplumber.extraConfig."51-bluez-policy" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-aac" = true;
      "bluez5.enable-aptx" = true;
      "bluez5.enable-aptx-hd" = true;
      "bluez5.enable-ldac" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
    };
    "monitor.bluez.rules" = [
      {
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "a2dp_sink" "hsp_hs" "hfp_hf" ];
          };
        };
      }
    ];
    "wireplumber.settings" = {
      "bluetooth.autoswitch-to-headset-profile" = false;
    };
  };

  # Step 4: Install useful tools
  environment.systemPackages = with pkgs; [
    pavucontrol
    blueman
    pipewire
    wireplumber
    bluez
  ];
}
```

## Troubleshooting

If you're still experiencing issues after following these steps:

1. **Restart audio services**:

   ```bash
   systemctl --user restart pipewire wireplumber
   sudo systemctl restart bluetooth
   ```

2. **Check for errors in logs**:

   ```bash
   journalctl --user -u pipewire -u wireplumber -n 50
   journalctl -u bluetooth -n 50
   ```

3. **Try different codec combinations** - Some devices don't support all codecs. Try commenting out some of the codec enablement lines to see if it helps.

## Conclusion

Bluetooth audio issues on NixOS can be frustrating, but they're solvable with the right configuration. The key is understanding that the problem isn't missing software, but rather how the system manages the complex negotiation between your device and the audio stack.

By following this guide, you've configured your system to:

- Prioritize high-quality audio profiles
- Enable all available high-fidelity codecs
- Prevent unwanted profile switching
- Maintain a clean, conflict-free audio environment

Your Bluetooth headphones should now deliver the rich, high-quality audio they were designed for.
