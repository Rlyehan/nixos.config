{
  pkgs,
  username,
  ...
}:
{
  # Enable Hyprland compositor with UWSM session manager
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Wayland Ozone layer for Electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Greeter — tuigreet launching Hyprland via UWSM
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = username;
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'uwsm start hyprland.desktop'";
      };
    };
  };

  # Hyprland-specific XDG portal config
  xdg.portal.configPackages = [
    pkgs.xdg-desktop-portal-hyprland
  ];

  # PAM — swaylock with fingerprint auth
  security.pam.services.swaylock.fprintAuth = true;

  # Hyprland cachix binary cache
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
