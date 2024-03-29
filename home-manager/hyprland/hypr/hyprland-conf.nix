{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig =
    ''
      exec-once=hypr_autostart
      exec-once=${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1

      $mainMod = WIN
      $scripts = $HOME/.config/hypr/scripts
      monitor=,highres,auto,2

      xwayland {
      force_zero_scaling = true
      }

      input {
      kb_layout=us
      follow_mouse=1
      touchpad {
      natural_scroll=no
      }
      }

      misc {
      mouse_move_enables_dpms = true
      key_press_enables_dpms = true
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
      # col.group_border=0xff89dceb
      # col.group_border_active=0xfff9e2af
      layout = dwindle # master|dwindle 
      }

      decoration {
      rounding=15
      drop_shadow = true
      shadow_range=100
      shadow_render_power=5
      col.shadow= 0x33000000
      col.shadow_inactive=0x22000000

      blur {
      enabled = true
      size = 3
      passes = 1
      new_optimizations = true
      xray = true
      ignore_opacity = false
      }
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
      bind = $mainMod SHIFT, Q, exec, hypr_kill
      bind = $mainMod, L, exec, myswaylock
      bind = $mainMod, Space, togglefloating,
      bind = $mainMod, F, fullscreen
      bind = $mainMod, Y, pin
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle
      bind = $mainMod, D, exec, wofi --show drun
      # bind = $mainMod, D, exec, ~/.config/rofi/scripts/launcher_t7
      bind = , Print, exec, gscreenshot

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
      # Move focus & window with mainMod + arrow keys #
      #--------------------------------------#
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      #----------------------------------#
      # move window in current workspace #
      #----------------------------------#
      bind = $mainMod SHIFT,left ,movewindow, h
      bind = $mainMod SHIFT,up ,movewindow, j
      bind = $mainMod SHIFT,down ,movewindow, k
      bind = $mainMod SHIFT,right ,movewindow, l

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
      bind = $mainMod, period, workspace, e+1
      bind = $mainMod, comma, workspace,e-1
      bind = $mainMod, M, workspace, 
      bind = $mainMod, C, workspace, 

      #-------------------------------#
      # special workspace(scratchpad) #
      #-------------------------------# 
      bind = $mainMod, minus, movetoworkspace,special
      bind = $mainMod, equal, togglespecialworkspace

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
      bind = $mainMod SHIFT, M, movetoworkspace, 
      bind = $mainMod SHIFT, C, movetoworkspace, 
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
      bind=,XF86TouchpadToggle,exec, $scripts/toggle_touchpad


      #---------------#
      # windows rules #
      #---------------#
      #`hyprctl clients` get class、title...
      windowrulev2=fullscreen, class:^(.*winbox64.*)$, title:^(.*WinBox.*)$
      windowrulev2=float, class:^(.*winbox64.*)$, title:^((?!WinBox).)*$
      windowrulev2=float,class:^(Brave-browser)$,title:^(Save File)$
      windowrulev2=workspace 1, class:^(Brave-browser)$
      windowrulev2=idleinhibit fullscreen, class:^(Brave-browser)$
      windowrulev2=workspace 3, class:^(jetbrains-studio)$, title:^((?!Running Devices).)*$
      windowrulev2=workspace 4, class:^(jetbrains-studio)$, title:^(.*Running Devices.*)$
      windowrulev2=tile, class:^(jetbrains-studio)$, title:^(.*Running Devices.*)$
      windowrulev2=workspace name:, class:^(Wavebox)$
      windowrule=workspace 2, title:^(Visual Studio Code)$
      windowrulev2=fakefullscreen, class:^(code-url-handler)$
    '';
}




