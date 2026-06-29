{
  pkgs,
  lib,
  host,
  ...
}:

with lib;
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-left = [
          "niri/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "pulseaudio"
          "battery"
          "tray"
          "custom/exit"
        ];

        "niri/workspaces" = {
          format = "{value}";
          all-outputs = false;
        };

        "clock" = {
          format = "  {:%H:%M · %a, %b %d}";
          format-alt = "  {:%A, %B %d}";
          tooltip-format = "<big>{:%A, %B %d %Y}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "  muted";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = ["" "" "" "" ""];
        };

        "tray" = {
          spacing = 8;
        };

        "custom/exit" = {
          format = "";
          on-click = "wlogout";
          tooltip = false;
        };
      }
    ];
    style = ''
      * {
        font-family: GeistMono Nerd Font Mono;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
      }

      tooltip {
        background: #1e1e2e;
        border: 1px solid #45475a;
        border-radius: 8px;
      }

      tooltip label {
        color: #cdd6f4;
      }

      #workspaces {
        margin: 4px 8px;
      }

      #workspaces button {
        padding: 4px 8px;
        margin: 0 2px;
        border-radius: 8px;
        color: #6c7086;
        background: transparent;
        transition: all 0.2s ease;
      }

      #workspaces button.active {
        color: #1e1e2e;
        background: #89b4fa;
      }

      #workspaces button.empty {
        color: #45475a;
      }

      #workspaces button:hover {
        color: #cdd6f4;
        background: #313244;
      }

      #clock {
        font-weight: bold;
        color: #cdd6f4;
      }

      #pulseaudio,
      #battery,
      #tray,
      #custom-exit {
        padding: 4px 12px;
        margin: 4px 2px;
        border-radius: 8px;
        background: #313244;
        color: #cdd6f4;
      }

      #pulseaudio {
        color: #f9e2af;
      }

      #battery {
        color: #a6e3a1;
      }

      #battery.warning {
        color: #fab387;
      }

      #battery.critical {
        color: #f38ba8;
      }

      #custom-exit {
        color: #f38ba8;
        padding: 4px 14px;
      }
    '';
  };
}
