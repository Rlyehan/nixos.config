{
  pkgs,
  host,
  ...
}:
{
  # Hyprland-specific home-manager imports
  imports = [
    ../../config/hyprland.nix
    ../../config/rofi/rofi.nix
    ../../config/rofi/config-long.nix
    ../../config/swaync.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
  ];

  # Wlogout icons
  home.file.".config/wlogout/icons" = {
    source = ../../config/wlogout;
    recursive = true;
  };

  # Hyprland-specific scripts
  home.packages = [
    (import ../../scripts/list-hypr-bindings.nix {
      inherit pkgs;
      inherit host;
    })
    (import ../../scripts/task-waybar.nix { inherit pkgs; })
    (import ../../scripts/rofi-launcher.nix { inherit pkgs; })
  ];

  services = {
    hypridle = {
      enable = true;
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
