{
  pkgs,
  username,
  lib,
  ...
}:
let
  colorScheme = import ../../config/colors.nix;
  colors = colorScheme.colors;

  # Convert "#RRGGBB" hex color to COSMIC RON RGBA tuple string
  # e.g. "#2f302f" -> "(red: 0.18..., green: 0.18..., blue: 0.18..., alpha: 1.0)"
  hexToRon = hex:
    let
      r = lib.fromHexString (builtins.substring 1 2 hex);
      g = lib.fromHexString (builtins.substring 3 2 hex);
      b = lib.fromHexString (builtins.substring 5 2 hex);
    in
    "(red: ${builtins.toString (r / 255.0)}, green: ${builtins.toString (g / 255.0)}, blue: ${builtins.toString (b / 255.0)}, alpha: 1.0)";
in
{
  # COSMIC ThemeBuilder — only override the fields we care about; COSMIC derives the rest
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/bg_color".text =
    "Some(${hexToRon colors.background})";
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/accent".text =
    "Some(${hexToRon colors.teal})";
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/text_tint".text =
    "Some(${hexToRon colors.foreground})";
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/neutral_tint".text =
    "Some(${hexToRon colors.foreground})";
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/is_frosted".text =
    "false";
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/gaps".text =
    "(4, 4)";
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/active_hint".text =
    "1";
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark.Builder/v1/corner_radii".text = ''
    (
        radius_0: (0, 0, 0, 0),
        radius_xs: (4, 4, 4, 4),
        radius_s: (8, 8, 8, 8),
        radius_m: (16, 16, 16, 16),
        radius_l: (32, 32, 32, 32),
        radius_xl: (160, 160, 160, 160),
    )
  '';

  # COSMIC Background — per-key config files
  home.file.".config/cosmic/com.system76.CosmicBackground/v1/all" = {
    force = true;
    text = ''
      (
          output: All,
          source: Path("/home/${username}/Pictures/Wallpapers/cool.jpg"),
          filter_by_theme: false,
          rotation_frequency: 300,
          filter_method: Lanczos,
          scaling_mode: Zoom,
          sampling_method: Alphanumeric,
      )
    '';
  };

  # COSMIC Toolkit — per-key config files
  home.file.".config/cosmic/com.system76.CosmicTk/v1/font_name".text = ''"Montserrat"'';
  home.file.".config/cosmic/com.system76.CosmicTk/v1/font_size".text = "(0, 11)";
  home.file.".config/cosmic/com.system76.CosmicTk/v1/font_weight".text = "400";
  home.file.".config/cosmic/com.system76.CosmicTk/v1/font_name_mono".text = ''"GeistMono Nerd Font Mono"'';
  home.file.".config/cosmic/com.system76.CosmicTk/v1/icon_theme_name".text = ''Some("Papirus-Dark")'';
  home.file.".config/cosmic/com.system76.CosmicTk/v1/show_maximize".text = "true";
  home.file.".config/cosmic/com.system76.CosmicTk/v1/show_minimize".text = "true";
  home.file.".config/cosmic/com.system76.CosmicTk/v1/apply_theme_global".text = "true";

  # COSMIC Terminal configuration
  home.file.".config/cosmic/com.system76.CosmicTerm/v1/font_name".text = ''"GeistMono Nerd Font Mono"'';

  home.file.".config/cosmic/com.system76.CosmicTerm/v1/font_size".text = "14";

  home.file.".config/cosmic/com.system76.CosmicTerm/v1/syntax_theme_dark".text = ''"Teal Custom"'';

  home.file.".config/cosmic/com.system76.CosmicTerm/v1/color_schemes_dark".text = ''
    {
        0: (
            name: "Teal Custom",
            foreground: "${colors.foreground}",
            background: "${colors.background}",
            cursor: "${colors.foreground}",
            bright_foreground: "${colors.bright_foreground}",
            dim_foreground: "${colors.foreground}",
            normal: (
                black: "${colors.black}",
                red: "${colors.teal}",
                green: "${colors.steel}",
                yellow: "${colors.aqua}",
                blue: "${colors.ocean}",
                magenta: "${colors.slate}",
                cyan: "${colors.cyan}",
                white: "${colors.white}",
            ),
            bright: (
                black: "${colors.bright_black}",
                red: "${colors.bright_teal}",
                green: "${colors.bright_steel}",
                yellow: "${colors.bright_aqua}",
                blue: "${colors.bright_ocean}",
                magenta: "${colors.bright_slate}",
                cyan: "${colors.bright_cyan}",
                white: "${colors.bright_white}",
            ),
        ),
    }
  '';

  home.file.".config/cosmic/com.system76.CosmicPanel.Panel/v1/opacity" = {
    text = "0.9";
    force = true;
  };

  home.file.".config/cosmic/com.system76.CosmicPanel.Panel/v1/background" = {
    force = true;
    text = let
    r = builtins.toString (lib.fromHexString (builtins.substring 1 2 colors.background) / 255.0);
    g = builtins.toString (lib.fromHexString (builtins.substring 3 2 colors.background) / 255.0);
    b = builtins.toString (lib.fromHexString (builtins.substring 5 2 colors.background) / 255.0);
  in "Color([${r}, ${g}, ${b}])";
  };

  # Display output configuration
  # LG 5K ultrawide — scale down from 200% to 150% for usable real estate
  home.file.".config/cosmic/com.system76.CosmicRandr/v1/outputs".text = ''
    {
        "DP-5": (
            mode: (5120, 2160, 59999),
            scale: 1.5,
            transform: Normal,
            position: (1920, 0),
            enabled: true,
        ),
        "eDP-1": (
            mode: (1920, 1200, 60001),
            scale: 1.0,
            transform: Normal,
            position: (0, 0),
            enabled: true,
        ),
    }
  '';

  # COSMIC Keybindings — complete map with 5 remapped bindings from Hyprland
  # Remapped: Super+Return→Terminal, Super+W→WebBrowser, Super+T→HomeFolder,
  #           Super+F→Fullscreen, Super+Shift+F→ToggleWindowFloating
  # Removed conflicting defaults: Super+t(Terminal), Super+b(WebBrowser),
  #   Super+f(HomeFolder), Super+F11(Fullscreen), Super+g(ToggleWindowFloating),
  #   Super+w(WorkspaceOverview)
  home.file.".config/cosmic/com.system76.CosmicComp/v1/key_bindings".text = ''
    {
        (modifiers: [Super, Alt], key: "Escape"): Terminate,
        (modifiers: [Super, Shift], key: "Escape"): System(LogOut),
        (modifiers: [Super, Ctrl], key: "Escape"): Debug,
        (modifiers: [Super], key: "Escape"): System(LockScreen),
        (modifiers: [Super], key: "q"): Close,
        (modifiers: [Alt], key: "F4"): Close,

        (modifiers: [Super], key: "Left"): Focus(Left),
        (modifiers: [Super], key: "Right"): Focus(Right),
        (modifiers: [Super], key: "Up"): Focus(Up),
        (modifiers: [Super], key: "Down"): Focus(Down),
        (modifiers: [Super], key: "h"): Focus(Left),
        (modifiers: [Super], key: "j"): Focus(Down),
        (modifiers: [Super], key: "k"): Focus(Up),
        (modifiers: [Super], key: "l"): Focus(Right),
        (modifiers: [Super], key: "u"): Focus(Out),
        (modifiers: [Super], key: "i"): Focus(In),
        (modifiers: [Super, Shift], key: "Left"): Move(Left),
        (modifiers: [Super, Shift], key: "Right"): Move(Right),
        (modifiers: [Super, Shift], key: "Up"): Move(Up),
        (modifiers: [Super, Shift], key: "Down"): Move(Down),
        (modifiers: [Super, Shift], key: "h"): Move(Left),
        (modifiers: [Super, Shift], key: "j"): Move(Down),
        (modifiers: [Super, Shift], key: "k"): Move(Up),
        (modifiers: [Super, Shift], key: "l"): Move(Right),

        (modifiers: [Super], key: "1"): Workspace(1),
        (modifiers: [Super], key: "2"): Workspace(2),
        (modifiers: [Super], key: "3"): Workspace(3),
        (modifiers: [Super], key: "4"): Workspace(4),
        (modifiers: [Super], key: "5"): Workspace(5),
        (modifiers: [Super], key: "6"): Workspace(6),
        (modifiers: [Super], key: "7"): Workspace(7),
        (modifiers: [Super], key: "8"): Workspace(8),
        (modifiers: [Super], key: "9"): Workspace(9),
        (modifiers: [Super], key: "0"): LastWorkspace,
        (modifiers: [Super, Shift], key: "1"): MoveToWorkspace(1),
        (modifiers: [Super, Shift], key: "2"): MoveToWorkspace(2),
        (modifiers: [Super, Shift], key: "3"): MoveToWorkspace(3),
        (modifiers: [Super, Shift], key: "4"): MoveToWorkspace(4),
        (modifiers: [Super, Shift], key: "5"): MoveToWorkspace(5),
        (modifiers: [Super, Shift], key: "6"): MoveToWorkspace(6),
        (modifiers: [Super, Shift], key: "7"): MoveToWorkspace(7),
        (modifiers: [Super, Shift], key: "8"): MoveToWorkspace(8),
        (modifiers: [Super, Shift], key: "9"): MoveToWorkspace(9),
        (modifiers: [Super, Shift], key: "0"): MoveToLastWorkspace,

        (modifiers: [Super, Ctrl], key: "Left"): PreviousWorkspace,
        (modifiers: [Super, Ctrl], key: "Down"): NextWorkspace,
        (modifiers: [Super, Ctrl], key: "Up"): PreviousWorkspace,
        (modifiers: [Super, Ctrl], key: "Right"): NextWorkspace,
        (modifiers: [Super, Ctrl], key: "h"): PreviousWorkspace,
        (modifiers: [Super, Ctrl], key: "j"): NextWorkspace,
        (modifiers: [Super, Ctrl], key: "k"): PreviousWorkspace,
        (modifiers: [Super, Ctrl], key: "l"): NextWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "Left"): MoveToPreviousWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "Down"): MoveToNextWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "Up"): MoveToPreviousWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "Right"): MoveToNextWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "h"): MoveToPreviousWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "j"): MoveToNextWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "k"): MoveToPreviousWorkspace,
        (modifiers: [Super, Shift, Ctrl], key: "l"): MoveToNextWorkspace,

        (modifiers: [Super, Alt], key: "Left"): SwitchOutput(Left),
        (modifiers: [Super, Alt], key: "Down"): SwitchOutput(Down),
        (modifiers: [Super, Alt], key: "Up"): SwitchOutput(Up),
        (modifiers: [Super, Alt], key: "Right"): SwitchOutput(Right),
        (modifiers: [Super, Alt], key: "h"): SwitchOutput(Left),
        (modifiers: [Super, Alt], key: "k"): SwitchOutput(Up),
        (modifiers: [Super, Alt], key: "j"): SwitchOutput(Down),
        (modifiers: [Super, Alt], key: "l"): SwitchOutput(Right),
        (modifiers: [Super, Shift, Alt], key: "Left"): MoveToOutput(Left),
        (modifiers: [Super, Shift, Alt], key: "Down"): MoveToOutput(Down),
        (modifiers: [Super, Shift, Alt], key: "Up"): MoveToOutput(Up),
        (modifiers: [Super, Shift, Alt], key: "Right"): MoveToOutput(Right),
        (modifiers: [Super, Shift, Alt], key: "h"): MoveToOutput(Left),
        (modifiers: [Super, Shift, Alt], key: "k"): MoveToOutput(Up),
        (modifiers: [Super, Shift, Alt], key: "j"): MoveToOutput(Down),
        (modifiers: [Super, Shift, Alt], key: "l"): MoveToOutput(Right),

        (modifiers: [Super], key: "o"): ToggleOrientation,
        (modifiers: [Super], key: "s"): ToggleStacking,
        (modifiers: [Super], key: "y"): ToggleTiling,
        (modifiers: [Super], key: "x"): SwapWindow,

        (modifiers: [Super], key: "m"): Maximize,
        (modifiers: [Super], key: "r"): Resizing(Outwards),
        (modifiers: [Super, Shift], key: "r"): Resizing(Inwards),

        (modifiers: [Super, Alt], key: "s"): System(ScreenReader),
        (modifiers: [Super], key: "equal"): ZoomIn,
        (modifiers: [Super], key: "minus"): ZoomOut,
        (modifiers: [Super], key: "period"): ZoomIn,
        (modifiers: [Super], key: "comma"): ZoomOut,

        (modifiers: [Super], key: "Return"): System(Terminal),
        (modifiers: [Super], key: "w"): System(WebBrowser),
        (modifiers: [Super], key: "t"): System(HomeFolder),
        (modifiers: [Super], key: "f"): Fullscreen,
        (modifiers: [Super, Shift], key: "f"): ToggleWindowFloating,

        (modifiers: [Super], key: "space"): System(InputSourceSwitch),
        (modifiers: [Super], key: "a"): System(AppLibrary),
        (modifiers: [Super], key: "slash"): System(Launcher),
        (modifiers: [Super]): System(Launcher),
        (modifiers: [Alt], key: "Tab"): System(WindowSwitcher),
        (modifiers: [Alt, Shift], key: "Tab"): System(WindowSwitcherPrevious),
        (modifiers: [Super], key: "Tab"): System(WindowSwitcher),
        (modifiers: [Super, Shift], key: "Tab"): System(WindowSwitcherPrevious),

        (modifiers: [], key: "Print"): System(Screenshot),
        (modifiers: [Super, Shift], key: "s"): System(Screenshot),
        (modifiers: [], key: "XF86AudioRaiseVolume"): System(VolumeRaise),
        (modifiers: [], key: "XF86AudioLowerVolume"): System(VolumeLower),
        (modifiers: [], key: "XF86AudioMute"): System(Mute),
        (modifiers: [], key: "XF86AudioMicMute"): System(MuteMic),
        (modifiers: [], key: "XF86MonBrightnessUp"): System(BrightnessUp),
        (modifiers: [], key: "XF86MonBrightnessDown"): System(BrightnessDown),
        (modifiers: [], key: "XF86AudioPlay"): System(PlayPause),
        (modifiers: [], key: "XF86AudioPrev"): System(PlayPrev),
        (modifiers: [], key: "XF86AudioNext"): System(PlayNext),
        (modifiers: [], key: "XF86PowerOff"): System(PowerOff),
        (modifiers: [], key: "XF86TouchpadToggle"): System(TouchpadToggle),
        (modifiers: [Super, Ctrl], key: "XF86TouchpadToggle"): System(TouchpadToggle),
        (modifiers: [], key: "XF86LaunchA"): System(WorkspaceOverview),
    }
  '';

  # Default terminal → Ghostty
  home.file.".config/cosmic/com.system76.CosmicComp/v1/xdg_shell_default_terminal".text = ''"ghostty"'';

  # Smaller dock
  home.file.".config/cosmic/com.system76.CosmicPanel.Dock/v1/size" = {
    text = "S";
    force = true;
  };

  # Touchpad: natural (inverted) scroll; mice unaffected
  home.file.".config/cosmic/com.system76.CosmicComp/v1/input_touchpad".text = ''
    (
        state: Enabled,
        acceleration: (
            profile: Some(Adaptive),
            speed: 0.0,
        ),
        click_method: Some(Clickfinger),
        scroll_config: (
            method: Some(TwoFinger),
            natural_scroll: Some(true),
        ),
        tap_config: (
            enabled: true,
            button_map: Some(LeftRightMiddle),
            drag: true,
            drag_lock: false,
        ),
        left_handed: false,
        middle_emulation: true,
        dwt: true,
        dwtp: true,
    )
  '';

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox"; # keep legacy path
    profiles.default = {
      settings = {
        "widget.gtk.libadwaita-colors.enabled" = false;
      };
    };
  };
}
