{
  pkgs,
  username,
  inputs,
  ...
}:
{
  # niri-flake NixOS module. This enables niri and wires up the components a
  # Wayland session needs on NixOS: xdg-desktop-portal-gnome (screencast),
  # a polkit authentication agent, the GNOME keyring, dconf, OpenGL, default
  # fonts, and a PAM entry for swaylock.
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri = {
    enable = true;
    # Use the nixpkgs build so we share the system cache and closure instead
    # of pulling niri from the flake's binary cache.
    package = pkgs.niri;
  };

  # We use pkgs.niri (from nixpkgs), so don't add the flake's Cachix substituter.
  niri-flake.cache.enable = false;

  # Wayland Ozone layer for Electron apps at the session level
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Greeter — tuigreet (same as the Hyprland setup) launching niri-session.
  # Using tuigreet gives an actual login screen; niri-session sets up the
  # systemd user session and imports the environment for spawned apps.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = username;
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
      };
    };
  };

  # XWayland support for X11-only apps. niri integrates xwayland-satellite when
  # it is available; we also start it explicitly from the niri config.
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  # Without this, NixOS injects a stripped PATH via Environment= on the niri
  # systemd unit, which shadows the user-manager PATH and causes spawned apps
  # to not find binaries. Disabling the default lets niri inherit the full PATH
  # set up by niri-session.
  systemd.user.services.niri.enableDefaultPath = false;
}
