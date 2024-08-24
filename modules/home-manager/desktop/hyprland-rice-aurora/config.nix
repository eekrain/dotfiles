{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.desktop.hyprland;
  hypr_kill = pkgs.writeShellScriptBin "hypr_kill" ''
    HYPRCMDS=$(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
    rm /tmp/hyprexitwithgrace.log
    hyprctl --batch "$HYPRCMDS" > /tmp/hyprexitwithgrace.log 2>&1
    swww clear #clearing current wallpaper, in case it was .gif, it take too long to initialize later on boot
    hyprctl dispatch exit
  '';
  initMyWallpaper = pkgs.writeShellScriptBin "initMyWallpaper" ''
    swww-daemon &
    sleep 1
    wall ~/Pictures/wallpapers/1.jpg #sets lightweigh wallpaper first
    sleep 10
    # then sets my favorite .gif wallpaper
    wall ~/Pictures/wallpapers/misono-mika-angel-blue-archive-moewalls.gif
  '';
in {
  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    home.packages = [
      # For waybar modules to read playing media
      pkgs.waybar-mpris
      initMyWallpaper
      hypr_kill
    ];

    wayland.windowManager.hyprland = {
      settings = {
        monitor = ",highres,auto,2";
        "$mod" = "WIN";

        xwayland = {
          force_zero_scaling = "true";
        };

        binds = {
          workspace_back_and_forth = "1";
          allow_workspace_cycles = "1";
          scroll_event_delay = 0;
        };

        bindm = [
          #-----------------------#
          # Mouse bind            #
          #-----------------------#
          "$mod,mouse:272,movewindow"
          "$mod,mouse:273,resizewindow"
        ];

        bind = mkMerge [
          [
            #-----------------------#
            # Keybind               #
            #-----------------------#
            "$mod, Return, exec, kitty zsh"
            ''$mod SHIFT, Return, exec, kitty --class="termfloat" zsh''
            "$mod, Q, killactive,"
            "$mod SHIFT, Q, exec, hypr_kill"
            "$mod, L, exec, hyprlock"
            "$mod, Space, togglefloating,"
            "$mod, F, fullscreen"
            "$mod, Y, pin"
            "$mod, P, pseudo, # dwindle"
            "$mod, J, togglesplit, # dwindle"
            "$mod, D, exec, wofi --show drun"
            ", Print, exec, gscreenshot"
          ]
          [
            #-----------------------#
            # Toggle grouped layout #
            #-----------------------#
            "$mod, K, togglegroup,"
            "$mod, Tab, changegroupactive, f"
          ]
          [
            #--------------------------------------------------#
            # Move focus & window with mainMod + arrow keys    #
            #--------------------------------------------------#
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"
          ]
          [
            #----------------------------------------#
            # Switch workspaces with mainMod + [0-9] #
            #----------------------------------------#
            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"
            "$mod, 0, workspace, 10"
            "$mod, M, workspace, "
            "$mod, C, workspace, "
            # Scroll through existing workspaces with mainMod + scroll
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"
            "$mod,slash,workspace,previous"
          ]
          [
            #-------------------------------#
            # special workspace(scratchpad) #
            #-------------------------------#
            "$mod, minus, movetoworkspace,special"
            "$mod, equal, togglespecialworkspace"
          ]
          [
            #-----------------------------------#
            # Move active window to a workspace #
            #-----------------------------------#
            "$mod SHIFT, 1, movetoworkspace, 1"
            "$mod SHIFT, 2, movetoworkspace, 2"
            "$mod SHIFT, 3, movetoworkspace, 3"
            "$mod SHIFT, 4, movetoworkspace, 4"
            "$mod SHIFT, 5, movetoworkspace, 5"
            "$mod SHIFT, 6, movetoworkspace, 6"
            "$mod SHIFT, 7, movetoworkspace, 7"
            "$mod SHIFT, 8, movetoworkspace, 8"
            "$mod SHIFT, 9, movetoworkspace, 9"
            "$mod SHIFT, 0, movetoworkspace, 10"
            "$mod SHIFT, M, movetoworkspace, "
            "$mod SHIFT, C, movetoworkspace, "
          ]
          [
            #-----------------------------------------#
            # Fn control, eg: volume,brightness,etc   #
            #-----------------------------------------#
            ",XF86AudioRaiseVolume,exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume,exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute,exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"
            ",XF86AudioMicMute,exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
            ",XF86MonBrightnessUp,exec, brightnessctl set '12.75+'"
            ",XF86MonBrightnessDown, exec, brightnessctl set '12.75-'"
            ",XF86AudioPlay,exec, mpc -q toggle"
            ",XF86AudioNext,exec, mpc -q next"
            ",XF86AudioPrev,exec, mpc -q prev"
            ",XF86TouchpadToggle,exec, $scripts/toggle_touchpad"
          ]
        ];

        windowrulev2 = [
          #---------------#
          # windows rules #
          #---------------#
          #`hyprctl clients` get class、title...

          "fullscreen, class:^(.*winbox64.*)$, title:^(.*WinBox.*)$"
          "float, class:^(.*winbox64.*)$, title:^((?!WinBox).)*$"
          "float,class:^(Brave-browser)$,title:^(Save File)$"
          "workspace 1, class:^(Brave-browser)$"
          "workspace 3, class:^(jetbrains-studio)$, title:^((?!Running Devices).)*$"
          "workspace 4, class:^(jetbrains-studio)$, title:^(.*Running Devices.*)$"
          "tile, class:^(jetbrains-studio)$, title:^(.*Running Devices.*)$"
          "workspace name:, class:^(Wavebox)$"
          "workspace 2, class:^(Code)$"
          "fakefullscreen, class:^(code-url-handler)$"
        ];

        input = {
          kb_layout = "us";
          numlock_by_default = true;
          repeat_delay = 250;
          repeat_rate = 35;

          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            clickfinger_behavior = true;
            scroll_factor = 0.5;
          };
          follow_mouse = 1;
        };

        misc = {
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          disable_autoreload = true;
          disable_hyprland_logo = true;
          always_follow_on_dnd = true;
          layers_hog_keyboard_focus = true;
          animate_manual_resizes = false;
          enable_swallow = true;
          focus_on_activate = true;
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 4;
          workspace_swipe_distance = 250;
          workspace_swipe_invert = true;
          workspace_swipe_min_speed_to_force = 5;
          workspace_swipe_cancel_ratio = 0.5;
          workspace_swipe_direction_lock = true;
          workspace_swipe_direction_lock_threshold = 10;
          workspace_swipe_create_new = false;
        };

        debug = {
          disable_logs = false;
        };

        # Aurora rice stuff
        dwindle = {
          pseudotile = "1"; # enable pseudotiling on dwindle
          force_split = "0";
        };

        general = {
          sensitivity = "1.0"; # for mouse cursor
          gaps_in = "3";
          gaps_out = "5";
          border_size = "3";
          "col.active_border" = "rgba(cba6f7ff) rgba(89b4faff) rgba(94e2d5ff) 10deg";
          "col.inactive_border" = "0xff45475a";
          apply_sens_to_raw = "0"; # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
          layout = "dwindle"; # master|dwindle
        };

        decoration = {
          rounding = "15";
          drop_shadow = "true";
          shadow_range = "100";
          shadow_render_power = "5";
          "col.shadow" = "0x33000000";
          "col.shadow_inactive" = "0x22000000";

          blur = {
            enabled = "true";
            size = "3";
            passes = "1";
            new_optimizations = "true";
            xray = "true";
            ignore_opacity = "false";
          };
        };

        exec-once = [
          "waybar"
          "dunst"
          "initMyWallpaper"

          "touchpadtoggle"
          "~/.config/hypr/scripts/tools/dynamic"
          ''notify-send -a aurora "hello $(whoami)"''

          "gtk-launch dev.zen.Zen.desktop"
          "gtk-launch motrix.desktop"
          # Disabling proxy on startup
          "proxytoggle"
        ];
      };

      extraConfig = ''
        animations {
          enabled=1
          # bezier=overshot,0.05,0.9,0.1,1.1
          bezier=overshot,0.13,0.99,0.29,1.1
          animation=windows,1,4,overshot,slide
          animation=border,1,10,default
          animation=fade,1,10,default
          animation=workspaces,1,6,overshot,slidevert
        }
      '';
    };
  };
}
