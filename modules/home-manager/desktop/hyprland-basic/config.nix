{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      monitor = ",highres,auto,2";
      "$mod" = "ALT";

      xwayland = {
        force_zero_scaling = "true";
      };

      binds = {
        workspace_back_and_forth = "1";
        allow_workspace_cycles = "1";
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
          "$mod, L, exec, myswaylock"
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
          ",XF86AudioRaiseVolume,exec, pamixer -i 5"
          ",XF86AudioLowerVolume,exec, pamixer -d 5"
          ",XF86AudioMute,exec, pamixer -t"
          ",XF86AudioMicMute,exec, pamixer --default-source -t"
          ",XF86MonBrightnessUp,exec, light -A 5"
          ",XF86MonBrightnessDown, exec, light -U 5"
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
        follow_mouse = "1";
        touchpad = {
          natural_scroll = "no";
        };
      };

      misc = {
        mouse_move_enables_dpms = "true";
        key_press_enables_dpms = "true";
        disable_autoreload = "true";
        disable_hyprland_logo = "true";
        always_follow_on_dnd = "true";
        layers_hog_keyboard_focus = "true";
        animate_manual_resizes = "false";
        enable_swallow = "true";
        focus_on_activate = "true";
      };

      gestures = {
        workspace_swipe = "true";
        workspace_swipe_fingers = "4";
        workspace_swipe_distance = "250";
        workspace_swipe_invert = "true";
        workspace_swipe_min_speed_to_force = "15";
        workspace_swipe_cancel_ratio = "0.5";
        workspace_swipe_create_new = "false";
      };

      debug = {
        disable_logs = false;
      };
    };
  };
}
