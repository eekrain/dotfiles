{ config, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    $mainMod = WIN
    monitor=,highres,auto,2
    # sets xwayland scale
    exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
    exec-once=hypr_autostart
    # toolkit-specific scale
    env = LIBSEAT_BACKEND,logind
    env = GDK_SCALE,2
    env = XCURSOR_SIZE,32


    input {
      kb_layout=us
      kb_variant=ffffff
      kb_model=
      kb_options=
      kb_rules=

      follow_mouse=1

      touchpad {
          natural_scroll=no
      }
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

    general {
      sensitivity=1.0 # for mouse cursor    
      gaps_in=8
      gaps_out=15
      border_size=3
      col.active_border=rgba(cba6f7ff) rgba(89b4faff) rgba(94e2d5ff) 10deg
      col.inactive_border=0xff45475a
      apply_sens_to_raw=0 # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
      col.group_border=0xff89dceb
      col.group_border_active=0xfff9e2af
      layout = dwindle # master|dwindle 
    }

    decoration {
      blur_new_optimizations = true
      drop_shadow = true
      shadow_range=100
      shadow_render_power=5
      col.shadow= 0x33000000
      col.shadow_inactive=0x22000000
      rounding=15
      blur=0
      blur_size=1 # minimum 1
      blur_passes=1 # minimum 1, more passes = more resource intensive.
      # Your blur "amount" is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
      # if you want heavy blur, you need to up the blur_passes.
      # the more passes, the more you can up the blur_size without noticing artifacts.
    }

    animations {
      enabled=1
      # bezier=overshot,0.05,0.9,0.1,1.1
      bezier=overshot,0.13,0.99,0.29,1.1
      animation=windows,1,4,overshot,slide
      animation=border,1,10,default
      animation=fade,1,10,default
      animation=workspaces,1,6,overshot,slidevert
    }

    
    dwindle {
        pseudotile=1 # enable pseudotiling on dwindle
        force_split=0
    }

    master{
        
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


    #-----------------------#
    # Keybind #
    #-----------------------#
    bindm = $mainMod,mouse:272,movewindow
    bindm = $mainMod,mouse:273,resizewindow
    bind = $mainMod, Return, exec, kitty zsh
    bind = $mainMod SHIFT, Return, exec, kitty --class="termfloat" zsh
    bind = $mainMod, Q, killactive,
    bind = $mainMod SHIFT, Q, exit,
    bind = $mainMod SHIFT, Space, togglefloating,
    bind = $mainMod,F,fullscreen
    bind = $mainMod,Y,pin
    bind = $mainMod, P, pseudo, # dwindle
    bind = $mainMod, J, togglesplit, # dwindle
    bind = $mainMod, D, exec, wofi --show drun

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
    bind = $mainMod, M, workspace,Music

    #-------------------------------#
    # special workspace(scratchpad) #
    #-------------------------------# 
    bind = $mainMod, minus, movetoworkspace,special
    bind = $mainMod, equal, togglespecialworkspace

    #----------------------------------#
    # move window in current workspace #
    #----------------------------------#
    bind = $mainMod SHIFT,left ,movewindow, h
    bind = $mainMod SHIFT,up ,movewindow, j
    bind = $mainMod SHIFT,down ,movewindow, k
    bind = $mainMod SHIFT,right ,movewindow, l

    #-----------------------------------#
    # Move active window to a workspace #
    #-----------------------------------#
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10
    bind = $mainMod SHIFT, left, movetoworkspace, -1
    bind = $mainMod SHIFT, right, movetoworkspace, +1
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
}
