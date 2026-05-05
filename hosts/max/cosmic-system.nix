{ pkgs, lib, ... }:
{
  # COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  # COSMIC greeter (display manager)
  services.displayManager.cosmic-greeter.enable = true;

  # System76 scheduler for performance optimization
  services.system76-scheduler.enable = true;

  # Disable power-profiles-daemon — COSMIC enables it by default,
  # but the shared config already uses auto-cpufreq which conflicts.
  services.power-profiles-daemon.enable = false;

  # Portal config: let COSMIC handle ScreenCast and Camera portals
  # Use COSMIC's portal instead of GTK for proper screen sharing/camera
  xdg.portal.extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-cosmic ];
  xdg.portal.configPackages = lib.mkForce [ pkgs.cosmic-comp ];

  # Enable PipeWire camera support for WebRTC (Teams, browser video calls)
  services.pipewire.extraConfig.pipewire."10-camera" = {
    "context.objects" = [
      {
        factory = "spa-node-factory";
        args = {
          "factory.name" = "api.libcamera.enum.manager";
        };
      }
    ];
  };

  # Env vars for Chromium-based apps (Teams, Brave) to use Wayland screen capture
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
