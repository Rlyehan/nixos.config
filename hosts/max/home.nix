{
  pkgs,
  username,
  host,
  ...
}:
let
  colorScheme = import ../../config/colors.nix;
  colors = colorScheme.colors;
in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  # Import Program Configurations
  imports = [
    ../../config/hyprland.nix
    ../../config/neovim.nix
    ../../config/rofi/rofi.nix
    ../../config/rofi/config-long.nix
    ../../config/swaync.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
    ../../config/starship.nix
    ../../config/zsh.nix
    ./git.nix
  ];

  # Place Files Inside Home Directory
  home.file."Pictures/Wallpapers" = {
    source = ../../config/wallpapers;
    recursive = true;
  };
  home.file.".config/wlogout/icons" = {
    source = ../../config/wlogout;
    recursive = true;
  };
  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=/home/${username}/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=Ubuntu
    paint_mode=brush
    early_exit=true
    fill_shape=false
  '';

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
    
    # GTK theme settings
    "org/gnome/desktop/interface" = {
      gtk-theme = "Arc-Dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 24;
      font-name = "GeistMono Nerd Font Mono 11";
      document-font-name = "GeistMono Nerd Font Mono 11";
      monospace-font-name = "GeistMono Nerd Font Mono 11";
      color-scheme = "prefer-dark";
      gtk-enable-primary-paste = true;
    };
    
    # File manager (Thunar) specific settings
    "org/gnome/desktop/default-applications/file-manager" = {
      exec = "thunar";
    };
    
    # Ensure icons are shown in menus and buttons (using proper GVariant format)
    "org/gnome/settings-daemon/plugins/xsettings" = {
      overrides = "{'Gtk/ButtonImages': <1>, 'Gtk/MenuImages': <1>, 'Gtk/ToolbarStyle': <'both'>, 'Gtk/ToolbarIconSize': <'large'>}";
    };
  };

  # Styling Options
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    enable = true;
    
    theme = {
      # Arc-Dark matches your teal-blue accent aesthetic better
      name = "Arc-Dark";
      package = pkgs.arc-theme;
      # Alternative that also works well with your colors:
      # name = "Materia-Dark-Compact"; 
      # package = pkgs.materia-theme;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
      # Alternative that matches your blue accents: "Tela-blue-dark"
    };
    
    font = {
      # Match your waybar font family
      name = "GeistMono Nerd Font Mono";
      size = 11;
    };
    
    gtk2.extraConfig = ''
      gtk-theme-name="Arc-Dark"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-font-name="GeistMono Nerd Font Mono 11"
      gtk-cursor-theme-name="Bibata-Modern-Ice"
      gtk-cursor-theme-size=24
      gtk-toolbar-style=GTK_TOOLBAR_BOTH
      gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images=1
      gtk-menu-images=1
      gtk-enable-event-sounds=1
      gtk-enable-input-feedback-sounds=1
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintfull"
    '';
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "Arc-Dark";
      gtk-icon-theme-name = "Papirus-Dark";
      gtk-font-name = "GeistMono Nerd Font Mono 11";
      gtk-cursor-theme-name = "Bibata-Modern-Ice";
      gtk-cursor-theme-size = 24;
      gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = 1;
      gtk-menu-images = 1;
      gtk-enable-event-sounds = 1;
      gtk-enable-input-feedback-sounds = 1;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "Arc-Dark";
      gtk-icon-theme-name = "Papirus-Dark";
      gtk-font-name = "GeistMono Nerd Font Mono 11";
      gtk-cursor-theme-name = "Bibata-Modern-Ice";
      gtk-cursor-theme-size = 24;
    };
  };
  
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };

  # Scripts
  home.packages = [
    # Existing scripts
    (import ../../scripts/task-waybar.nix { inherit pkgs; })
    (import ../../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ../../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ../../scripts/screenshootin.nix { inherit pkgs; })
    (import ../../scripts/list-hypr-bindings.nix {
      inherit pkgs;
      inherit host;
    })
    
    # GTK theming and icon packages
    pkgs.arc-theme             # Primary choice - matches your blue/teal accents
    pkgs.materia-theme         # Alternative dark theme option  
    pkgs.gnome-themes-extra      # Provides Adwaita and other themes
    pkgs.orchis-theme           # Modern alternative theme (commented option above)
    pkgs.papirus-icon-theme      # High-quality icon theme
    pkgs.hicolor-icon-theme      # Base icon theme (required)
    pkgs.adwaita-icon-theme # GNOME's default icon theme (fills gaps)
    pkgs.numix-icon-theme        # Alternative comprehensive icon theme
    pkgs.elementary-xfce-icon-theme # Good for Thunar specifically
    
    # Font packages for better text rendering (ensure GeistMono is available)
    pkgs.dejavu_fonts
    pkgs.liberation_ttf
    pkgs.source-code-pro
    pkgs.geist-font           # Includes GeistMono Nerd Font
    
    # Additional blue/teal friendly icon themes
    pkgs.tela-icon-theme      # Has blue variants that match your accent colors
    pkgs.qogir-icon-theme     # Another good option with blue accents
    
    # GTK tools for debugging/configuration
    pkgs.gtk3
    pkgs.gtk4
    pkgs.glib # Provides gsettings
  ];

  services = {
    hypridle = {
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "swaylock";
          };
        listener = [
          {
            timeout = 900;
            on-timeout = "swaylock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  programs = {
    gh.enable = true;
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };

  kitty = {
  enable = true;
  settings = {
    # Colors
      background = colors.background;
      foreground = colors.foreground;
      selection_background = colors.selection_bg;
      selection_foreground = colors.selection_fg;
      cursor = colors.cursor;
      cursor_text_color = colors.cursor_text;

      # Normal colors
      color0 = colors.black;
      color1 = colors.red;
      color2 = colors.green;
      color3 = colors.yellow;
      color4 = colors.blue;
      color5 = colors.magenta;
      color6 = colors.cyan;
      color7 = colors.white;

      # Bright colors
      color8 = colors.bright_black;
      color9 = colors.bright_red;
      color10 = colors.bright_green;
      color11 = colors.bright_yellow;
      color12 = colors.bright_blue;
      color13 = colors.bright_magenta;
      color14 = colors.bright_cyan;
      color15 = colors.bright_white;

    # Font configuration
    font_family = "GeistMono Nerd Font Mono";
    font_size = 14;

    # Window configuration
    background_opacity = "0.8";
    window_padding_width = 8;
  };
  };

    direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
    };

    home-manager.enable = true;
    swaylock = {
      enable = true;
      settings = {
      color = "2f302f";
      bs-hl-color = "4e9ba7";  
      caps-lock-bs-hl-color = "4e9ba7";  
      caps-lock-key-hl-color = "6998b4";  
      key-hl-color = "6998b4"; 
      inside-color = "00000000";
      inside-clear-color = "00000000";
      inside-caps-lock-color = "00000000";
      inside-ver-color = "00000000";
      inside-wrong-color = "00000000";
      layout-bg-color = "00000000";
      layout-border-color = "00000000";
      layout-text-color = "e9eaeb";  
      line-color = "00000000";
      line-clear-color = "00000000";
      line-caps-lock-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";   
      ring-color = "4b9bac";  
      ring-clear-color = "4e9ba7";  
      ring-caps-lock-color = "50a2af";  
      ring-ver-color = "6998b4";  
      ring-wrong-color = "4e9ba7";  
      separator-color = "00000000";
      text-color = "e9eaeb";
      text-clear-color = "f5f6f7";
      text-caps-lock-color = "f5f6f7";
      text-ver-color = "f5f6f7";
      text-wrong-color = "f5f6f7";
    };
    };
  };
}
