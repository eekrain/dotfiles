{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.screenshot = mkEnableOption "Enable screenshot script";

  config = mkIf cfg.screenshot {
    home.packages = with pkgs; [
      # --- Screenshot Tool Dependencies ---
      grimblast # Modern screenshot tool with built-in freeze support
      satty
      # grimblast already includes these in its wrapper: grim, slurp, wl-clipboard, hyprpicker, hyprland, jq, coreutils, libnotify

      # --- The Screenshot Tool Script (Using grimblast) ---
      (writeShellScriptBin "screenshot" ''
        case "$1" in
          full)
            # Mode 1: Freeze the screen, capture full output, then open in satty.
            echo "🖼️ Freezing screen for full capture and edit..."
            # Capture the full output and pipe directly to satty.
            grimblast -f -c save screen - | satty -f -
            ;;
          region)
            # Mode 2: Freeze the screen, let user select a region, then open in satty.
            echo "✂️ Freezing screen for region capture and edit..."
            # Freeze the screen, let user select a region, and pipe directly to satty.
            grimblast -f save area - | satty -f -
            ;;
          copy)
            # Mode 3: Freeze the screen, let user select a region, and copy to clipboard.
            echo "📋 Freezing screen for region capture and copy..."
            grimblast -f copy area
            ;;
          *)

            # Fallback: Display a usage message.
            echo "Usage: screenshot {full|region|copy}"
            echo "  full   - Freeze the screen, capture the entire monitor, and edit."
            echo "  region - Freeze the screen, select a region, and edit."
            echo "  copy   - Freeze the screen, select a region, and copy to clipboard."
            exit 1
            ;;
        esac
      '')
    ];
  };
}
