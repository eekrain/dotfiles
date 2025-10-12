{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.cli;

  # Define the script using writeShellScriptBin
  clip2path = pkgs.writeShellScriptBin "clip2path" ''
    #!/usr/bin/env bash
    # A script to paste clipboard content into the active Kitty window.
    # It prioritizes file paths, then text, and falls back to saving images.

    set -euo pipefail

    # Debug: Log to a temporary file
    debug_log="/tmp/clip2path_debug.log"
    echo "[$(date)] clip2path started" >> "$debug_log"

    # Get the list of clipboard types
    types=$(wl-paste --list-types 2>> "$debug_log" || echo "ERROR_GETTING_TYPES")
    echo "[$(date)] Clipboard types: $types" >> "$debug_log"

    # Check if the clipboard contains an image (check this first!)
    if grep -qE '^image/' <<<"$types"; then
      echo "[$(date)] Detected image content" >> "$debug_log"
      # Get the first image type
      image_type=$(grep -m1 '^image/' <<<"$types")
      echo "[$(date)] Using image type: $image_type" >> "$debug_log"
      ext=$(echo "$image_type" | cut -d/ -f2 | cut -d';' -f1)
      file="/tmp/clip_$(date +%s).''${ext}"
      echo "[$(date)] Saving image to: $file" >> "$debug_log"
      # Specify the mime type when pasting
      wl-paste --type "$image_type" > "$file"
      # Output the path in double quotes
      echo "\"$file\"" | kitty @ send-text --stdin
      notify-send "Clipboard" "Image saved to: <u>''${file}</u>" &
    # Check if the clipboard contains a URI list (file paths)
    elif printf '%s\n' "$types" | grep -qFx 'text/uri-list'; then
      echo "[$(date)] Processing URI list" >> "$debug_log"
      uri_list=$(wl-paste --type 'text/uri-list')
      first_uri=$(head -n 1 <<<"$uri_list")
      file_path=$(printf '%b' "''${first_uri//%/\\x}" | sed 's|^file://||')
      echo "[$(date)] File path: $file_path" >> "$debug_log"
      # Output the path in double quotes
      echo "\"$file_path\"" | kitty @ send-text --stdin
    # Check if the clipboard contains plain text
    elif printf '%s\n' "$types" | grep -qFx 'text/plain'; then
      echo "[$(date)] Processing regular text" >> "$debug_log"
      # Regular text
      wl-paste --no-newline | kitty @ send-text --stdin
    else
      echo "[$(date)] Using fallback for unknown type" >> "$debug_log"
      # Fallback for any other type
      wl-paste --no-newline | kitty @ send-text --stdin
    fi
    echo "[$(date)] clip2path finished" >> "$debug_log"
  '';

  # Define the ccp script to copy clipboard content to .claude/context
  ccp = pkgs.writeShellScriptBin "ccp" ''
    #!/usr/bin/env bash
    # A script to paste clipboard content to .claude/context directory

    set -euo pipefail

    # Get the current working directory
    current_dir="$(pwd)"
    context_dir="$current_dir/.claude/context"

    # Create the .claude/context directory if it doesn't exist
    mkdir -p "$context_dir"

    # Get the list of clipboard types
    types=$(wl-paste --list-types 2>/dev/null || echo "ERROR_GETTING_TYPES")

    # Check if the clipboard contains an image
    if grep -qE '^image/' <<<"$types"; then
      # Get the first image type
      image_type=$(grep -m1 '^image/' <<<"$types")
      ext=$(echo "$image_type" | cut -d/ -f2 | cut -d';' -f1)

      # Generate a unique filename with timestamp
      timestamp=$(date +%s)
      file="$context_dir/clip_''${timestamp}.''${ext}"

      # Save the image with the proper MIME type
      wl-paste --type "$image_type" > "$file"

      # Output the relative path from current directory
      rel_path=".claude/context/clip_''${timestamp}.''${ext}"
      echo "Image saved to: $rel_path"
      echo "Full path: $file"

      # Send notification
      notify-send "CCP" "Image saved to: <u>''${rel_path}</u>" &
    # Check if the clipboard contains text
    elif grep -qE '^text/' <<<"$types"; then
      # Get the text content
      content=$(wl-paste --no-newline)

      # Check if the content looks like CSS (contains common CSS properties)
      if echo "$content" | grep -qE "(display:|position:|width:|height:|background:|color:|margin:|padding:|flex-direction:|align-items:|gap:|border-radius:|box-shadow:)"; then
        # Save as CSS
        file="$context_dir/figma.css"
        echo "$content" > "$file"

        # Output the relative path from current directory
        rel_path=".claude/context/figma.css"
        echo "CSS saved to: $rel_path"
        echo "Full path: $file"

        # Send notification
        notify-send "CCP" "CSS saved to: <u>''${rel_path}</u>" &
      else
        # Save as regular text file
        timestamp=$(date +%s)
        file="$context_dir/clip_''${timestamp}.txt"
        echo "$content" > "$file"

        # Output the relative path from current directory
        rel_path=".claude/context/clip_''${timestamp}.txt"
        echo "Text saved to: $rel_path"
        echo "Full path: $file"

        # Send notification
        notify-send "CCP" "Text saved to: <u>''${rel_path}</u>" &
      fi
    else
      echo "Error: No supported content found in clipboard" >&2
      exit 1
    fi
  '';
in {
  options.myHmModules.cli.kitty = mkEnableOption "Enable kitty settings";
  config = mkIf cfg.kitty {
    # 1. Add the script and its dependencies to your packages
    home.packages = with pkgs; [
      wl-clipboard # For wl-paste
      libnotify # For notify-send
      coreutils # For date, head, cut, etc.
      gnugrep # For grep
      clip2path # The script defined above
      ccp # The script to copy images to .claude/context
    ];

    # 2. Configure Kitty with the new settings and keybinding
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Macchiato";
      font.name = "CaskaydiaCove Nerd Font Mono";
      font.size = 12;
      settings = {
        italic_font = "auto";
        bold_italic_font = "auto";
        mouse_hide_wait = 2;
        cursor_shape = "block";
        url_color = "#0087bd";
        url_style = "dotted";
        confirm_os_window_close = 0;
        background_opacity = "0.95";

        # --- New Settings ---
        # Allow remote control so kitty @ send-text works
        allow_remote_control = "yes";

        # Bind Ctrl+V to run the script by its name, since it's now in the PATH
        map = "ctrl+v launch --type=background --allow-remote-control --keep-focus clip2path";
      };
    };
  };
}
