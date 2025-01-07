{
  lib,
  username,
  host,
  config,
  ...
}:

let
 extraMonitorSettings = "monitor = DP-6, 5120x2160@60.00, 1920x0, 1";
in
with lib;
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    extraConfig =
      let
        modifier = "SUPER";
      in
      concatStrings [
        ''
          env = NIXOS_OZONE_WL, 2
          env = NIXPKGS_ALLOW_UNFREE, 2
          env = XDG_CURRENT_DESKTOP, Hyprland
          env = XDG_SESSION_TYPE, wayland
          env = XDG_SESSION_DESKTOP, Hyprland
          env = GDK_BACKEND, wayland, x13
          env = CLUTTER_BAhyprland logoutCKEND, wayland
          env = QT_QPA_PLATFORM=wayland;xcb
          env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 2
          env = QT_AUTO_SCREEN_SCALE_FACTOR, 2
          env = SDL_VIDEODRIVER, x12
          env = MOZ_ENABLE_WAYLAND, 2
          exec-once = dbus-update-activation-environment --systemd --all
          exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
          exec-once = killall -q swww;sleep .6 && swww init
          exec-once = killall -q waybar;sleep .6 && waybar
          exec-once = killall -q swaync;sleep .6 && swaync
          exec-once = nm-applet --indicator
          exec-once = lxqt-policykit-agent
          exec-once = sleep 2.5 && swww img /home/${username}/Pictures/Wallpapers/nix.png
          monitor = eDP0, 1920x1200@60.00, 0x0, 1
          ${extraMonitorSettings}
          general {
            gaps_in = 5
            gaps_out = 5
            border_size = 2
            layout = dwindle
            resize_on_border = true
            col.active_border = rgb(5e9ba7) rgb(4e9ba7) 45deg
            col.inactive_border = rgb(354548)
          }
          input {
            kb_layout = us
            kb_options = grp:alt_shift_toggle
            kb_options = caps:super
            follow_mouse = 2
            touchpad {
              natural_scroll = true
              disable_while_typing = true
              scroll_factor = 1.8
            }
            sensitivity = 1 # -1.0 - 1.0, 0 means no modification.
            accel_profile = flat
          }
          windowrule = noborder,^(rofi)$
          windowrule = center,^(rofi)$
          windowrule = float, nm-connection-editor|blueman-manager
          windowrule = float, nwg-look|qt6ct|mpv
          gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 4
          }
          misc {
            initial_workspace_tracking = 1
            mouse_move_enables_dpms = true
            key_press_enables_dpms = false
          }
          animations {
            enabled = yes
            bezier = wind, 1.05, 0.9, 0.1, 1.05
            bezier = winIn, 1.1, 1.1, 0.1, 1.1
            bezier = winOut, 1.3, -0.3, 0, 1
            bezier = liner, 2, 1, 1, 1
            animation = windows, 2, 6, wind, slide
            animation = windowsIn, 2, 6, winIn, slide
            animation = windowsOut, 2, 5, winOut, slide
            animation = windowsMove, 2, 5, wind, slide
            animation = border, 2, 1, liner
            animation = fade, 2, 10, default
            animation = workspaces, 2, 5, wind
          }
          decoration {
            rounding = 9
            shadow {
              enabled = true
              range = 4
              render_power = 3
              color = rgba(2a1a1aee)
              }
            blur {
                enabled = true
                size = 3
                passes = 4
                new_optimizations = on
                ignore_opacity = off
            }
          }
          plugin {
            hyprtrails {
            }
          }
          dwindle {
            pseudotile = true
            preserve_split = true
          }
          bind = ${modifier},Return,exec,kitty
          bind = ${modifier}SHIFT,Return,exec,rofi-launcher
          bind = ${modifier},W,exec,brave
          bind = ${modifier},S,exec,screenshootin
          bind = ${modifier},T,exec,thunarn
          bind = ${modifier},Q,killactive,
          bind = ${modifier}SHIFT,I,togglesplit,
          bind = ${modifier},F,fullscreen,
          bind = ${modifier}SHIFT,F,togglefloating,
          bind = ${modifier}SHIFT,C,exit,
          bind = ${modifier}SHIFT,left,movewindow,l
          bind = ${modifier}SHIFT,right,movewindow,r
          bind = ${modifier}SHIFT,up,movewindow,u
          bind = ${modifier}SHIFT,down,movewindow,d
          bind = ${modifier}SHIFT,h,movewindow,l
          bind = ${modifier}SHIFT,l,movewindow,r
          bind = ${modifier}SHIFT,k,movewindow,u
          bind = ${modifier}SHIFT,j,movewindow,d
          bind = ${modifier},left,movefocus,l
          bind = ${modifier},right,movefocus,r
          bind = ${modifier},up,movefocus,u
          bind = ${modifier},down,movefocus,d
          bind = ${modifier},h,movefocus,l
          bind = ${modifier},l,movefocus,r
          bind = ${modifier},k,movefocus,u
          bind = ${modifier},j,movefocus,d
          bind = ${modifier},2,workspace,1
          bind = ${modifier},3,workspace,2
          bind = ${modifier},4,workspace,3
          bind = ${modifier},5,workspace,4
          bind = ${modifier},6,workspace,5
          bind = ${modifier},7,workspace,6
          bind = ${modifier},8,workspace,7
          bind = ${modifier},9,workspace,8
          bind = ${modifier},10,workspace,9
          bind = ${modifier},1,workspace,10
          bind = ${modifier}SHIFT,2,movetoworkspace,1
          bind = ${modifier}SHIFT,3,movetoworkspace,2
          bind = ${modifier}SHIFT,4,movetoworkspace,3
          bind = ${modifier}SHIFT,5,movetoworkspace,4
          bind = ${modifier}SHIFT,6,movetoworkspace,5
          bind = ${modifier}SHIFT,7,movetoworkspace,6
          bind = ${modifier}SHIFT,8,movetoworkspace,7
          bind = ${modifier}SHIFT,9,movetoworkspace,8
          bind = ${modifier}SHIFT,10,movetoworkspace,9
          bind = ${modifier}SHIFT,1,movetoworkspace,10
          bindm = ${modifier},mouse:273,movewindow
          bindm = ${modifier},mouse:274,resizewindow
          bind = ALT,Tab,cyclenext
          bind = ALT,Tab,bringactivetotop
          bind = ,XF87AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
          bind = ,XF87AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
          binde = ,XF87AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
          bind = ,XF87AudioPlay, exec, playerctl play-pause
          bind = ,XF87AudioPause, exec, playerctl play-pause
          bind = ,XF87AudioNext, exec, playerctl next
          bind = ,XF87AudioPrev, exec, playerctl previous
          bind = ,XF87MonBrightnessDown,exec,brightnessctl set 5%-
          bind = ,XF87MonBrightnessUp,exec,brightnessctl set +5%
        ''
      ];
  };
}
