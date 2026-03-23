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

  # Ensure COSMIC portal is used instead of GTK portal
  xdg.portal.configPackages = lib.mkForce [ pkgs.cosmic-comp ];
}
