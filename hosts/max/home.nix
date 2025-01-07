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
  };

  # Styling Options
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };


  # Scripts
  home.packages = [
    (import ../../scripts/task-waybar.nix { inherit pkgs; })
    (import ../../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ../../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ../../scripts/screenshootin.nix { inherit pkgs; })
    (import ../../scripts/list-hypr-bindings.nix {
      inherit pkgs;
      inherit host;
    })
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
