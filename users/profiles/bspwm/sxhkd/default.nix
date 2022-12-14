{ config, pkgs, ... }:
{
  xdg.configFile."sxhkd/scripts".source = ./scripts;

  services.sxhkd = {
    enable = true;

    keybindings = {
      # ##############################################################################
      # #                                 APPLICATIONS                               #
      # ##############################################################################
      # Open web browser, and file manager.
      "super + shift + {b,f}" = "	{brave,thunar}";
      # Open terminal.
      "super + Return" = ''wezterm'';
      # Open application menu.
      "super + d" = "sh $HOME/.local/share/bin/appmnu";

      # ##############################################################################
      # #                                   HOTKEYS                                  #
      # ##############################################################################
      # Toggle control center.
      "super + shift + {d,c}" = "sh $HOME/.config/eww/scripts/openControlCenter.sh";

      # Toggle notification center.
      "super + shift + n" = "sh $HOME/.config/eww/scripts/openNotificationCenter.sh";

      # Toggle info center.
      "super + shift + i" = "sh $HOME/.config/eww/scripts/openInfoCenter.sh";

      # ##############################################################################
      # #                                 CONTROL KEYS                               #
      # ##############################################################################
      # Raise/lower volume.
      "XF86Audio{Raise,Lower}Volume" = "amixer -q set Master 5%{+,-}";
      # Mute/unmute volume.
      "XF86AudioMute" = "sh $HOME/.config/sxhkd/scripts/audioToggle.sh";
      # Toggle touchpad
      "XF86TouchpadToggle" = "sh $HOME/.config/sxhkd/scripts/touchpadToggle.sh";
      # Raise/lower brightness.
      "XF86MonBrightness{Up,Down}" = "brightnessctl set 5%{+,-}";
      # Raise/lower brightness to maximum or minimum.
      "super + XF86MonBrightness{Up,Down}" = "brightnessctl set {100%,30%}";
      # Screenshot; Save to local storage.
      "super + Print" = ''FILENAME=$(date '+%d-%m-%Y_%H:%M:%S.png'); maim -us "$HOME/Pictures/Screenshots/$FILENAME"; sh $HOME/.local/share/bin/viewscr $HOME/Pictures/Screenshots/$FILENAME'';

      # ##############################################################################
      # #                                 WINDOW KEYS                                #
      # ##############################################################################
      # Cycle focus through windows.
      "super + {_,shift + }Tab" = "bspc node -f {prev,next}.local.!hidden.window";
      # Kill the focused window.
      "super + {_,shift + }q" = "bspc node -{c,k}";
      # Move the focused window by direction.
      "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";
      # Move to or send window to workspace.
      # "super + {_,shift + }{1-5}" = "bspc {desktop -f,node -d} '^{1-5}'";
      # Move active  workspace.
      "super + {1-5}" = "bspc desktop -f '^{1-5}'";
      #Move window to workspace and follow it
      "super + shift + {1-5}" = ''id=$(bspc query -N -n); bspc node -d ^{1-5}; bspc node -f $id'';
      # Shrink focused window.
      "super + shift + { h, j, k, l }" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
      "super + shift + {Right,Up,Down,Left}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
      # Expand focused window.
      "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
      "super + alt + {Right,Up,Down,Left}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
      # Set window state.
      "super + { t, shift + t,space,f }" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen";
      # Set window ratio  
      "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}";
      # Set new window orientation.
      "super + ctrl + { h, j, k, l }" = "bspc node -p {west,south,north,east}";
      "super + ctrl + {Left,Down,Up,Right}" = "bspc node - p { west, south, north, east }";
      # Cancel the new window orientation.
      "super + ctrl + space" = "bspc node - p cancel";

      # ##############################################################################
      # #                             WINDOW MANAGER KEYS                            #
      # ##############################################################################
      # Restart sxhkd.
      "super + ctrl + r" = ''pkill -USR1 -x sxhkd; notify-send "sxhkd" "Restarted successfully."'';
      # Quit/restart bspwm.
      "super + ctrl + { q, alt +r }" = "bspc {quit,wm -r}";
      # Force restart eww.
      "super + ctrl + e" = "pkill eww && /etc/profiles/per-user/$USER/bin/eww open bar &; pkill ewwFullscreenFix.sh; $HOME/.config/bspwm/scripts/ewwFullscreenFix.sh &";


      # ##############################################################################
      # #                                MOUSE HOTKEYS                               #
      # ##############################################################################

      # Close all active notifications.
      # ~button1
      #	bspc query -D -d '.focused.!occupied' && eww update noti=false; sleep 0.270; eww close notification-popup; pkill openEwwPopup.sh

      # Toggle control center using middle click.
      # ~button2
      # 	bspc query -D -d '.focused.!occupied' && sh $HOME/.config/eww/scripts/openControlCenter.sh

      # Toggle right click context menu.
      "~button3" = ''bspc query -D -d '.focused.!occupied' && [[ ! -f "$HOME/.cache/eww-escreen.lock " ]] && echo -e "$(cat ~/.config/jgmenu/menu.txt) " | jgmenu --simple'';
    };
  };
}
