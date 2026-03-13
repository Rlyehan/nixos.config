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
    ../../config/starship.nix
    ../../config/zsh.nix
    ./git.nix
  ];

  # Place Files Inside Home Directory
  home.file."Pictures/Wallpapers" = {
    source = ../../config/wallpapers;
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
  
  home.file.".config/ghostty/config".text = ''
    # Theme - Options: Catppuccin Mocha, Catppuccin Frappe, Catppuccin Macchiato, Catppuccin Latte
    theme = Catppuccin Mocha
    
    # Font
    font-family = GeistMono Nerd Font Mono
    font-size = 11
    
    # Window
    window-padding-x = 10
    window-padding-y = 10
    
    # Other settings
    shell-integration-features = no-cursor
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
    
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
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
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    font = {
      name = "GeistMono Nerd Font Mono";
      size = 11;
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
    # Wrapper to expose kiro-cli's `kiro` binary as `kiro-cli` (avoids conflict with kiro GUI package)
    (pkgs.writeShellScriptBin "kiro-cli" ''
      exec ${pkgs.kiro-cli}/bin/kiro-cli "$@"
    '')

    # Existing scripts
    (import ../../scripts/screenshootin.nix { inherit pkgs; })

    # GTK theming
    pkgs.arc-theme
    pkgs.papirus-icon-theme
    pkgs.hicolor-icon-theme
    pkgs.elementary-xfce-icon-theme
  ];

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

      # Normal colors (monochromatic teal palette)
      color0 = colors.black;
      color1 = colors.teal;
      color2 = colors.steel;
      color3 = colors.aqua;
      color4 = colors.ocean;
      color5 = colors.slate;
      color6 = colors.cyan;
      color7 = colors.white;

      # Bright colors
      color8 = colors.bright_black;
      color9 = colors.bright_teal;
      color10 = colors.bright_steel;
      color11 = colors.bright_aqua;
      color12 = colors.bright_ocean;
      color13 = colors.bright_slate;
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
  };
}
