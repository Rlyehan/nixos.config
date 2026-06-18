{
  pkgs,
  ...
}:
{
  # Niri-specific home-manager imports
  imports = [
    ../../config/niri.nix
    ../../config/rofi/rofi.nix
    ../../config/rofi/config-long.nix
    ../../config/swaync.nix
    ../../config/waybar-niri.nix
    ../../config/wlogout-niri.nix
  ];

  # Wlogout icons
  home.file.".config/wlogout/icons" = {
    source = ../../config/wlogout;
    recursive = true;
  };

  # Niri-specific scripts
  home.packages = [
    (import ../../scripts/task-waybar.nix { inherit pkgs; })
    (import ../../scripts/rofi-launcher.nix { inherit pkgs; })
  ];

  # Idle management via swayidle (niri's recommended idle/lock approach)
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
    timeouts = [
      {
        timeout = 900;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 1200;
        command = "niri msg action power-off-monitors";
      }
    ];
  };

  # Screen locker — swaylock styled to match the teal palette
  programs.swaylock = {
    enable = true;
    settings = {
      color = "2f302f";
      inside-color = "2f302f";
      line-color = "2f302f";
      ring-color = "4b9bac";
      key-hl-color = "4e9ba7";
      bs-hl-color = "6998b4";
      text-color = "e9eaeb";
      indicator-radius = 80;
      indicator-thickness = 8;
      font = "GeistMono Nerd Font Mono";
      show-failed-attempts = true;
    };
  };
}
