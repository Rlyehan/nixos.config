{
  pkgs,
  username,
  host,
  ...
}:
let
  gitUsername = "Rlyehan";
  gitEmail = "maximilian.hub@proton.me";
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
          lock_cmd = "hyprlock";
          };
        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
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
    background = "#2f302f";
    foreground = "#e9eaeb";
    selection_background = "#2a6d95";
    selection_foreground = "#e9eaeb";
    cursor = "#e9eaeb";
    cursor_text_color = "#2f302f";

    # Normal colors
    color0 = "#2f302f";  # black
    color1 = "#4e9ba7";  # red
    color2 = "#6998b4";  # green
    color3 = "#50a2af";  # yellow
    color4 = "#4b9bac";  # blue
    color5 = "#4b9bac";  # magenta
    color6 = "#4e9ba7";  # cyan
    color7 = "#e9eaeb";  # white

    # Bright colors
    color8 = "#50a2af";   # bright black
    color9 = "#4e9ba7";   # bright red
    color10 = "#6998b4";  # bright green
    color11 = "#50a2af";  # bright yellow
    color12 = "#4b9bac";  # bright blue
    color13 = "#4b9bac";  # bright magenta
    color14 = "#4e9ba7";  # bright cyan
    color15 = "#f5f6f7";  # bright white

    # Font configuration
    font_family = "GeistMono Nerd Font Mono";
    font_size = 14;

    # Window configuration
    background_opacity = "0.8";
    window_padding_width = 8;
  };
  };

  alacritty = {
    enable = true;
    settings = {
      colors = {
        bright = {
          black = "#50a2af";
          blue = "#4b9bac";
          cyan = "#4e9ba7";
          green = "#6998b4";
          magenta = "#4b9bac";
          red = "#4e9ba7";
          white = "#f5f6f7";
          yellow = "#50a2af";
        };
        
        cursor = {
          cursor = "#e9eaeb";
          text = "#2f302f";
        };
        
        normal = {
          black = "#2f302f";
          blue = "#4b9bac";
          cyan = "#4e9ba7";
          green = "#6998b4";
          magenta = "#4b9bac";
          red = "#4e9ba7";
          white = "#e9eaeb";
          yellow = "#50a2af";
        };
        
        primary = {
          background = "#2f302f";
          bright_foreground = "#f5f6f7";
          foreground = "#e9eaeb";
        };
        
        selection = {
          background = "#2a6d95";
          text = "#e9eaeb";
        };
      };
      
      font = {
        size = 14;
        normal = {
          family = "GeistMono Nerd Font Mono";
          style = "Regular";
        };
      };
      
      window = {
        opacity = 0.8;
        padding = {
          x = 8;
          y = 8;
        };
      };
    };
  };

    direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
    };

    home-manager.enable = true;
    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 10;
          hide_cursor = true;
          no_fade_in = false;
        };
      };
    };
  };
}
