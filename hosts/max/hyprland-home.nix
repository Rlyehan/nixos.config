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
    hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };
        auth = {
          fingerprint.enabled = true;
        };
        background = [
          {
            color = "rgb(2f302f)";
          }
        ];
        input-field = [
          {
            size = "200, 50";
            outline_thickness = 3;
            outer_color = "rgb(4b9bac)";
            inner_color = "rgb(2f302f)";
            font_color = "rgb(e9eaeb)";
            check_color = "rgb(6998b4)";
            fail_color = "rgb(4e9ba7)";
            placeholder_text = "";
          }
        ];
      };
    };
  };
}
