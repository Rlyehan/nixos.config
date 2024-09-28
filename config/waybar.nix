{
  pkgs,
  lib,
  host,
  config,
  ...
}:

let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
in
with lib;
{
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-center = [ "hyprland/workspaces" ];
        modules-left = [
          "custom/startmenu"
          "hyprland/window"
          "pulseaudio"
          "cpu"
          "memory"
          "idle_inhibitor"
        ];
        modules-right = [
          "custom/hyprbindings"
          "custom/notification"
          "custom/exit"
          "battery"
          "tray"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };
        "clock" = {
          format = '' {:L%H:%M}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = " {free}";
          tooltip = true;
        };
        "network" = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = " {bandwidthDownOctets}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
          tooltip = false;
        };
        "tray" = {
          spacing = 12;
        };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pavucontrol";
        };
        "custom/exit" = {
          tooltip = false;
          format = "";
          on-click = "sleep 0.1 && wlogout";
        };
        "custom/startmenu" = {
          tooltip = false;
          format = "";
          # exec = "rofi -show drun";
          on-click = "sleep 0.1 && rofi-launcher";
        };
        "custom/hyprbindings" = {
          tooltip = false;
          format = "󱕴";
          on-click = "sleep 0.1 && list-hypr-bindings";
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = "true";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = false;
        };
      }
    ];
    style = concatStrings [
      ''
      * {
        font-family: GeistMono Nerd Font Mono;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      window#waybar {
        background: rgba(0, 0, 0, 0.2);
        color: #${config.stylix.base16Scheme.base05};
      }

      #workspaces {
        background: transparent;
        margin: 0 4px;
        padding: 0;
      }

      #workspaces button {
        font-weight: bold;
        padding: 0 3px;
        margin: 0 2px;
        border-radius: 5px;
        color: #${config.stylix.base16Scheme.base00};
        background: linear-gradient(45deg, #${config.stylix.base16Scheme.base08}, #${config.stylix.base16Scheme.base0D});
        opacity: 0.5;
        transition: ${betterTransition};
      }

      #workspaces button.active {
        opacity: 1.0;
        min-width: 35px;
      }

      #workspaces button:hover {
        opacity: 0.8;
      }

      tooltip {
        background: #${config.stylix.base16Scheme.base00};
        border: 1px solid #${config.stylix.base16Scheme.base08};
        border-radius: 5px;
      }

      tooltip label {
        color: #${config.stylix.base16Scheme.base08};
      }

      #window, #pulseaudio, #cpu, #memory, #idle_inhibitor,
      #custom-hyprbindings, #network, #battery, #custom-notification, #tray, #custom-exit {
        font-weight: bold;
        padding: 0 10px;
        margin: 0 2px;
        border-radius: 5px;
      }

      #window, #pulseaudio, #cpu, #memory, #idle_inhibitor {
        background: #${config.stylix.base16Scheme.base04};
        color: #${config.stylix.base16Scheme.base00};
      }

      #custom-startmenu {
        color: #${config.stylix.base16Scheme.base0B};
        background: #${config.stylix.base16Scheme.base02};
        font-size: 18px;
        padding: 0 10px;
        margin: 0 2px;
        border-radius: 5px;
      }

      #custom-hyprbindings, #network, #battery,
      #custom-notification, #tray, #custom-exit {
        background: #${config.stylix.base16Scheme.base0F};
        color: #${config.stylix.base16Scheme.base00};
      }

      #clock {
        font-weight: bold;
        color: #0D0E15;
        background: linear-gradient(90deg, #${config.stylix.base16Scheme.base0E}, #${config.stylix.base16Scheme.base0C});
        padding: 0 10px;
        margin: 0 2px;
        border-radius: 5px;
      }

      /* Ensure vertical centering and consistent height */
      #workspaces, #window, #pulseaudio, #cpu, #memory, #idle_inhibitor,
      #custom-hyprbindings, #network, #battery, #custom-notification, #tray, #custom-exit,
      #clock, #custom-startmenu {
        height: 24px;
        line-height: 24px;
      }
      ''
    ];
  };
}
