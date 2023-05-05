{ config, lib, pkgs, ... }:

{
  imports = [
    ./theme/catppuccin-dark
    ./programs
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };

    extraConfig = ''
      $mainMod = WIN
      monitor=,highres,auto,2
      # sets xwayland scale
      exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      exec-once=hypr_autostart
      # toolkit-specific scale
      env = GDK_SCALE,2
      env = XCURSOR_SIZE,32

      input {
        kb_layout = us
      }

      general {
        gaps_in = 3
        gaps_out = 5
        border_size = 3
        col.active_border = rgb(ffc0cb)
        col.inactive_border = rgba(595959aa)

        layout = dwindle # master|dwindle 
      }

      dwindle {
        no_gaps_when_only = false
        force_split = 0 
        special_scale_factor = 0.8
        split_width_multiplier = 1.0 
        use_active_for_splits = true
        pseudotile = yes 
        preserve_split = yes 
      }

      master {
        new_is_master = true
        special_scale_factor = 0.8
        new_is_master = true
        no_gaps_when_only = false
      }

      # cursor_inactive_timeout = 0
      decoration {
        multisample_edges = true
        active_opacity = 1.0
        inactive_opacity = 1.0
        fullscreen_opacity = 1.0
        rounding = 0
        blur = yes 
        blur_size = 3
        blur_passes = 1
        blur_new_optimizations = true
        blur_xray = true

        drop_shadow = false
        shadow_range = 4
        shadow_render_power = 3
        shadow_ignore_window = true
      # col.shadow = 
      # col.shadow_inactive
      # shadow_offset
        dim_inactive = false
      # dim_strength = #0.0 ~ 1.0
        blur_ignore_opacity = false
        col.shadow = rgba(1a1a1aee)
      }

      # animations {
      #   enabled = yes
      #
      #   bezier = easeOutElastic, 0.05, 0.9, 0.1, 1.05
      #   # bezier=overshot,0.05,0.9,0.1,1.1
      #
      #   animation = windows, 1, 5, easeOutElastic
      #   animation = windowsOut, 1, 5, default, popin 80%
      #   animation = border, 1, 8, default
      #   animation = fade, 1, 5, default
      #   animation = workspaces, 1, 6, default
      # }
      animations {
        enabled=1
        bezier = overshot, 0.13, 0.99, 0.29, 1.1
        animation = windows, 1, 4, overshot, slide
        animation = windowsOut, 1, 5, default, popin 80%
        animation = border, 1, 5, default
        animation = fade, 1, 8, default
        animation = workspaces, 1, 6, overshot, slidevert
      }


      gestures {
        workspace_swipe = true
        workspace_swipe_fingers = 4
        workspace_swipe_distance = 250
        workspace_swipe_invert = true
        workspace_swipe_min_speed_to_force = 15
        workspace_swipe_cancel_ratio = 0.5
        workspace_swipe_create_new = false
      }

      misc {
        disable_autoreload = true
        disable_hyprland_logo = true
        always_follow_on_dnd = true
        layers_hog_keyboard_focus = true
        animate_manual_resizes = false
        enable_swallow = true
        swallow_regex =
        focus_on_activate = true
      }


      bind = $mainMod, Return, exec, kitty zsh
      bind = $mainMod SHIFT, Return, exec, kitty --class="termfloat" zsh
      bind = $mainMod, Q, killactive,
      bind = $mainMod SHIFT, Q, exit,
      bind = $mainMod SHIFT, Space, togglefloating,
      bind = $mainMod,F,fullscreen
      bind = $mainMod,Y,pin
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle


      #-----------------------#
      # Toggle grouped layout #
      #-----------------------#
      bind = $mainMod, K, togglegroup,
      bind = $mainMod, Tab, changegroupactive, f

      #------------#
      # change gap #
      #------------#
      bind = $mainMod SHIFT, G,exec,hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"
      bind = $mainMod , G,exec,hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0"

      #--------------------------------------#
      # Move focus with mainMod + arrow keys #
      #--------------------------------------#
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      #----------------------------------------#
      # Switch workspaces with mainMod + [0-9] #
      #----------------------------------------#
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      bind = $mainMod, L, workspace, +1
      bind = $mainMod, H, workspace, -1
      bind = $mainMod, period, workspace, e+1
      bind = $mainMod, comma, workspace,e-1
      bind = $mainMod, Q, workspace,QQ
      bind = $mainMod, T, workspace,TG
      bind = $mainMod, M, workspace,Music

      #-------------------------------#
      # special workspace(scratchpad) #
      #-------------------------------# 
      bind = $mainMod, minus, movetoworkspace,special
      bind = $mainMod, equal, togglespecialworkspace

      #----------------------------------#
      # move window in current workspace #
      #----------------------------------#
      bind = $mainMod SHIFT,left ,movewindow, l
      bind = $mainMod SHIFT,right ,movewindow, r
      bind = $mainMod SHIFT,up ,movewindow, u
      bind = $mainMod SHIFT,down ,movewindow, d

      #---------------------------------------------------------------#
      # Move active window to a workspace with mainMod + ctrl + [0-9] #
      #---------------------------------------------------------------#
      bind = $mainMod CTRL, 1, movetoworkspace, 1
      bind = $mainMod CTRL, 2, movetoworkspace, 2
      bind = $mainMod CTRL, 3, movetoworkspace, 3
      bind = $mainMod CTRL, 4, movetoworkspace, 4
      bind = $mainMod CTRL, 5, movetoworkspace, 5
      bind = $mainMod CTRL, 6, movetoworkspace, 6
      bind = $mainMod CTRL, 7, movetoworkspace, 7
      bind = $mainMod CTRL, 8, movetoworkspace, 8
      bind = $mainMod CTRL, 9, movetoworkspace, 9
      bind = $mainMod CTRL, 0, movetoworkspace, 10
      bind = $mainMod CTRL, left, movetoworkspace, -1
      bind = $mainMod CTRL, right, movetoworkspace, +1
      # same as above, but doesnt switch to the workspace
      bind = $mainMod SHIFT, 1, movetoworkspacesilent, 1
      bind = $mainMod SHIFT, 2, movetoworkspacesilent, 2
      bind = $mainMod SHIFT, 3, movetoworkspacesilent, 3
      bind = $mainMod SHIFT, 4, movetoworkspacesilent, 4
      bind = $mainMod SHIFT, 5, movetoworkspacesilent, 5
      bind = $mainMod SHIFT, 6, movetoworkspacesilent, 6
      bind = $mainMod SHIFT, 7, movetoworkspacesilent, 7
      bind = $mainMod SHIFT, 8, movetoworkspacesilent, 8
      bind = $mainMod SHIFT, 9, movetoworkspacesilent, 9
      bind = $mainMod SHIFT, 0, movetoworkspacesilent, 10
      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      #-------------------------------------------#
      # switch between current and last workspace #
      #-------------------------------------------#
      binds {
           workspace_back_and_forth = 1 
           allow_workspace_cycles = 1
      }
      bind=$mainMod,slash,workspace,previous
      

      #-----------------------------------------#
      # control volume,brightness,media players-#
      #-----------------------------------------#
      bind=,XF86AudioRaiseVolume,exec, pamixer -i 5
      bind=,XF86AudioLowerVolume,exec, pamixer -d 5
      bind=,XF86AudioMute,exec, pamixer -t
      bind=,XF86AudioMicMute,exec, pamixer --default-source -t
      bind=,XF86MonBrightnessUp,exec, light -A 5
      bind=,XF86MonBrightnessDown, exec, light -U 5
      bind=,XF86AudioPlay,exec, mpc -q toggle 
      bind=,XF86AudioNext,exec, mpc -q next 
      bind=,XF86AudioPrev,exec, mpc -q prev
    '';
  };
}
