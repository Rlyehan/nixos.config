{
  config,
  username,
  ...
}:

let
  colorScheme = import ./colors.nix;
  colors = colorScheme.colors;

  # niri-flake exposes every niri action as a Nix value/function here, which
  # gives us build-time validation of action names and arguments.
  inherit (config.lib.niri.actions)
    spawn
    close-window
    maximize-column
    fullscreen-window
    toggle-window-floating
    toggle-column-tabbed-display
    toggle-overview
    center-column
    switch-preset-column-width
    switch-preset-column-width-back
    set-column-width
    set-window-height
    consume-or-expel-window-left
    consume-or-expel-window-right
    focus-column-left
    focus-column-right
    focus-window-up
    focus-window-down
    move-column-left
    move-column-right
    move-window-up
    move-window-down
    focus-monitor-left
    focus-monitor-right
    focus-monitor-up
    focus-monitor-down
    move-column-to-monitor-left
    move-column-to-monitor-right
    move-column-to-monitor-up
    move-column-to-monitor-down
    focus-workspace
    focus-workspace-down
    focus-workspace-up
    move-column-to-workspace-down
    move-column-to-workspace-up
    focus-workspace-previous
    show-hotkey-overlay
    power-off-monitors
    toggle-keyboard-shortcuts-inhibit
    quit
    ;

  teal = { color = colors.teal; };
in
{
  programs.niri.settings = {
    # ---- Outputs / scaling ---------------------------------------------------
    # Mirrors the COSMIC display setup: the LG 5K ultrawide (DP-5) scaled to
    # 150%, and the internal panel (eDP-1) at 100%. Outputs that aren't
    # connected are simply ignored, so this is safe when undocked.
    outputs = {
      "DP-5" = {
        mode = {
          width = 5120;
          height = 2160;
          refresh = 59.999;
        };
        scale = 1.5;
        position = {
          x = 1920;
          y = 0;
        };
        # Enable VRR (Adaptive Sync) only when a window opts in via the
        # variable-refresh-rate window rule below (e.g. video players).
        variable-refresh-rate = "on-demand";
      };
      "eDP-1" = {
        mode = {
          width = 1920;
          height = 1200;
          refresh = 60.001;
        };
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
      };
    };

    # ---- Input ---------------------------------------------------------------
    input = {
      keyboard.xkb = {
        layout = "us";
        options = "grp:alt_shift_toggle,caps:super";
      };
      touchpad = {
        tap = true;
        dwt = true;
        dwtp = true;
        natural-scroll = true;
        scroll-method = "two-finger";
      };
      mouse.accel-profile = "flat";
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
    };

    # ---- Cursor --------------------------------------------------------------
    # Laptop niceties: hide the cursor while typing and after a period of
    # inactivity so it doesn't sit on top of what you're reading.
    cursor = {
      hide-when-typing = true;
      hide-after-inactive-ms = 5000;
    };

    # ---- Environment ---------------------------------------------------------
    # Variables for processes spawned by niri (Wayland-native apps, etc.)
    environment = {
      NIXOS_OZONE_WL = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # ---- Startup -------------------------------------------------------------
    spawn-at-startup = [
      { argv = [ "swaync" ]; }
      { argv = [ "nm-applet" "--indicator" ]; }
      { argv = [ "awww-daemon" ]; }
      { sh = "systemctl --user reset-failed waybar.service"; }
      { sh = "sleep 2 && awww img /home/${username}/Pictures/Wallpapers/cool.jpg"; }
    ];

    # Ask clients to drop client-side decorations so niri draws clean borders.
    prefer-no-csd = true;

    # Don't show the hotkey overlay every time niri starts.
    hotkey-overlay.skip-at-startup = true;

    # ---- Layout / styling (matches the Hyprland teal theme) ------------------
    layout = {
      gaps = 4;
      center-focused-column = "never";

      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      default-column-width.proportion = 0.5;

      # Hyprland draws a border around every window (teal active, dark
      # inactive), so use niri's border and disable the focus ring.
      focus-ring.enable = false;
      border = {
        enable = true;
        width = 1;
        active = teal;
        inactive.color = "#354547";
      };

      # Subtle shadow, matching the Hyprland decoration shadow.
      shadow = {
        enable = true;
        softness = 10;
        spread = 2;
        offset = {
          x = 0;
          y = 3;
        };
        color = "#1a1a1aee";
      };

      # Tab indicator for tabbed columns (Mod+Shift+I), themed teal to match
      # the border/focus styling.
      tab-indicator = {
        active = teal;
        inactive.color = "#354547";
      };
    };

    # ---- Overview ------------------------------------------------------------
    # Theme the overview (Mod+O) backdrop with the dark base color so it
    # blends with the shadow/border palette.
    overview = {
      backdrop-color = "#1a1a1a";
    };

    # ---- Animations ----------------------------------------------------------
    animations.enable = true;

    # ---- Window rules --------------------------------------------------------
    window-rules = [
      # Rounded corners for all windows (Hyprland rounding = 8).
      {
        geometry-corner-radius = {
          top-left = 8.0;
          top-right = 8.0;
          bottom-left = 8.0;
          bottom-right = 8.0;
        };
        clip-to-geometry = true;
      }
      # Float utility/dialog windows.
      {
        matches = [
          { app-id = "^nm-connection-editor$"; }
          { app-id = "^blueman-manager$"; }
          { app-id = "^pavucontrol$"; }
          { app-id = "^org\\.pulseaudio\\.pavucontrol$"; }
          { app-id = "^nwg-look$"; }
          { app-id = "^qt5ct$"; }
          { app-id = "^mpv$"; }
          { app-id = "^vlc$"; }
          { app-id = "^swayimg$"; }
          { app-id = "^file-roller$"; }
        ];
        open-floating = true;
      }
      # Firefox/Brave picture-in-picture as floating.
      {
        matches = [ { title = "^Picture-in-Picture$"; } ];
        open-floating = true;
      }
      # Brave: slight transparency like the Hyprland opacity rule.
      {
        matches = [ { app-id = "^[Bb]rave"; } ];
        opacity = 0.95;
      }
      # Opt these windows into VRR on outputs set to "on-demand" (DP-5).
      {
        matches = [
          { app-id = "^mpv$"; }
          { app-id = "^vlc$"; }
        ];
        variable-refresh-rate = true;
      }
      # Block sensitive chats from screencasts (still screenshot-able). Use
      # "screen-capture" instead if you also want them hidden from wlr-screencopy.
      {
        matches = [
          { app-id = "^[Ss]lack$"; }
          { app-id = "^signal$"; }
        ];
        block-out-from = "screencast";
      }
    ];

    # ---- Key bindings (aligned with the Hyprland bindings) -------------------
    binds = {
      "Mod+Shift+Slash".action = show-hotkey-overlay;

      # Launchers
      "Mod+Return" = {
        repeat = false;
        action = spawn "ghostty";
      };
      "Mod+Space" = {
        repeat = false;
        action = spawn "rofi-launcher";
      };
      "Mod+Shift+Return" = {
        repeat = false;
        action = spawn "rofi-launcher";
      };
      "Mod+W".action = spawn "brave";
      "Mod+T".action = spawn "thunar";
      "Mod+S".action = spawn "screenshootin";

      # Window management
      "Mod+Q".action = close-window;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+V".action = toggle-window-floating;
      "Mod+Shift+I".action = toggle-column-tabbed-display;
      "Mod+Shift+C".action = quit;

      # Focus (vim keys + arrows)
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-window-up;
      "Mod+Down".action = focus-window-down;
      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;
      "Mod+K".action = focus-window-up;
      "Mod+J".action = focus-window-down;

      # Move windows/columns
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Down".action = move-window-down;
      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+K".action = move-window-up;
      "Mod+Shift+J".action = move-window-down;

      # Multi-monitor focus
      "Mod+Ctrl+Left".action = focus-monitor-left;
      "Mod+Ctrl+Right".action = focus-monitor-right;
      "Mod+Ctrl+Up".action = focus-monitor-up;
      "Mod+Ctrl+Down".action = focus-monitor-down;
      "Mod+Ctrl+H".action = focus-monitor-left;
      "Mod+Ctrl+L".action = focus-monitor-right;
      "Mod+Ctrl+K".action = focus-monitor-up;
      "Mod+Ctrl+J".action = focus-monitor-down;

      # Move columns to monitors
      "Mod+Ctrl+Shift+Left".action = move-column-to-monitor-left;
      "Mod+Ctrl+Shift+Right".action = move-column-to-monitor-right;
      "Mod+Ctrl+Shift+Up".action = move-column-to-monitor-up;
      "Mod+Ctrl+Shift+Down".action = move-column-to-monitor-down;
      "Mod+Ctrl+Shift+H".action = move-column-to-monitor-left;
      "Mod+Ctrl+Shift+L".action = move-column-to-monitor-right;
      "Mod+Ctrl+Shift+K".action = move-column-to-monitor-up;
      "Mod+Ctrl+Shift+J".action = move-column-to-monitor-down;

      # Workspaces by name
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;
      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;

      # Workspace cycling with PageUp/PageDown
      "Ctrl+Page_Up".action = focus-workspace-up;
      "Ctrl+Page_Down".action = focus-workspace-down;
      "Ctrl+Shift+Page_Up".action = move-column-to-workspace-up;
      "Ctrl+Shift+Page_Down".action = move-column-to-workspace-down;

      # Scrollable-tiling column controls
      "Mod+BracketLeft".action = consume-or-expel-window-left;
      "Mod+BracketRight".action = consume-or-expel-window-right;
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-column-width-back;
      "Mod+C".action = center-column;
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      # Overview
      "Mod+O" = {
        repeat = false;
        action = toggle-overview;
      };

      # Workspace scrolling with the mouse wheel
      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action = focus-workspace-down;
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action = focus-workspace-up;
      };
      "Mod+Ctrl+WheelScrollDown" = {
        cooldown-ms = 150;
        action = move-column-to-workspace-down;
      };
      "Mod+Ctrl+WheelScrollUp" = {
        cooldown-ms = 150;
        action = move-column-to-workspace-up;
      };

      "Alt+Tab".action = focus-workspace-previous;

      # Session
      "Mod+X".action = spawn "wlogout";
      "Super+Alt+L".action = spawn "swaylock";

      # Screenshots (niri built-ins; attrset form is the documented escape
      # hatch for interactive actions not exposed as helper functions)
      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      # Audio (work even when locked)
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      };

      # Media
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action = spawn "playerctl" "play-pause";
      };
      "XF86AudioPause" = {
        allow-when-locked = true;
        action = spawn "playerctl" "play-pause";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action = spawn "playerctl" "next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action = spawn "playerctl" "previous";
      };

      # Brightness
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action = spawn "brightnessctl" "set" "5%-";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action = spawn "brightnessctl" "set" "+5%";
      };

      # Misc
      "Mod+Shift+P".action = power-off-monitors;
      "Mod+Escape" = {
        allow-inhibiting = false;
        action = toggle-keyboard-shortcuts-inhibit;
      };
    };
  };
}
