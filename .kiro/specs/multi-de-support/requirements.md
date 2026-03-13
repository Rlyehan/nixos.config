# Requirements Document

## Introduction

Refactor the existing NixOS flake configuration to support multiple desktop environments (DEs) while sharing common system and home-manager configuration. The current setup is a single Hyprland-based configuration where shared system config and DE-specific config are interleaved in the same files. The goal is to cleanly separate shared config from DE-specific config, enabling the user to define multiple `nixosConfigurations` in `flake.nix` and switch between DEs (starting with Hyprland and COSMIC) via `nixos-rebuild switch --flake .#<config-name>`.

## Glossary

- **Flake**: The top-level `flake.nix` file that defines NixOS system configurations, inputs, and outputs
- **NixOS_Module**: A Nix file that contributes system-level configuration (services, programs, boot, hardware, etc.)
- **Home_Manager_Module**: A Nix file that contributes user-level configuration (dotfiles, user services, user packages) via home-manager
- **Shared_System_Config**: The subset of `hosts/max/config.nix` that is DE-agnostic (boot, networking, locale, fonts, hardware, security, virtualization, nix settings, etc.)
- **Shared_Home_Config**: The subset of `hosts/max/home.nix` that is DE-agnostic (neovim, starship, zsh, git, kitty, GTK/Qt theming, cursor, XDG dirs, dconf, btop, direnv, gh, ghostty, swappy, wallpapers, user packages)
- **DE_System_Module**: A NixOS_Module containing system-level configuration specific to a single desktop environment
- **DE_Home_Module**: A Home_Manager_Module containing user-level configuration specific to a single desktop environment
- **Hyprland_System_Module**: The DE_System_Module for Hyprland (programs.hyprland, greetd with tuigreet/UWSM, xdg.portal with hyprland portal, PAM swaylock entries, hyprland cachix substituter)
- **Hyprland_Home_Module**: The DE_Home_Module for Hyprland (hyprland.nix, rofi, waybar, wlogout, swaync, swaylock, hypridle, list-hypr-bindings script)
- **COSMIC_System_Module**: The DE_System_Module for COSMIC DE (cosmic-greeter, cosmic desktop manager, optionally system76-scheduler)
- **COSMIC_Home_Module**: The DE_Home_Module for COSMIC DE (placeholder for future COSMIC-specific home-manager config)
- **Configuration_Name**: The attribute name under `nixosConfigurations` in the Flake used to select a DE variant (e.g., `max-hyprland`, `max-cosmic`)

## Requirements

### Requirement 1: Shared System Configuration Extraction

**User Story:** As a NixOS user, I want shared system configuration separated from DE-specific configuration, so that common settings are defined once and reused across all DE variants.

#### Acceptance Criteria

1. THE Shared_System_Config SHALL contain all DE-agnostic system-level settings from the current `hosts/max/config.nix`, including boot, networking, locale, fonts, hardware, security, virtualization, nix settings, services (pipewire, printing, bluetooth, flatpak, openssh, etc.), and system packages.
2. THE Shared_System_Config SHALL import `hardware.nix` and `users.nix` as it does today.
3. THE Shared_System_Config SHALL NOT contain any Hyprland-specific configuration (programs.hyprland, greetd hyprland command, xdg.portal hyprland packages, PAM swaylock, hyprland cachix substituter).
4. WHEN a DE variant includes the Shared_System_Config, THE DE variant SHALL receive all shared system settings without duplication.

### Requirement 2: Hyprland System Module

**User Story:** As a Hyprland user, I want Hyprland-specific system configuration in its own module, so that it can be included only when building the Hyprland variant.

#### Acceptance Criteria

1. THE Hyprland_System_Module SHALL enable `programs.hyprland` with `withUWSM = true`.
2. THE Hyprland_System_Module SHALL configure `services.greetd` to launch Hyprland via tuigreet and UWSM (`uwsm start hyprland.desktop`).
3. THE Hyprland_System_Module SHALL configure `xdg.portal` with `xdg-desktop-portal-hyprland` in `configPackages`.
4. THE Hyprland_System_Module SHALL configure `security.pam.services.swaylock` and `security.pam.services.swaylock.fprintAuth`.
5. THE Hyprland_System_Module SHALL add the Hyprland cachix substituter and trusted public key to `nix.settings`.
6. THE Hyprland_System_Module SHALL set `environment.sessionVariables.NIXOS_OZONE_WL = "1"`.

### Requirement 3: COSMIC System Module

**User Story:** As a NixOS user, I want a COSMIC DE system module, so that I can build a NixOS configuration that runs the COSMIC desktop environment.

#### Acceptance Criteria

1. THE COSMIC_System_Module SHALL enable `services.desktopManager.cosmic`.
2. THE COSMIC_System_Module SHALL enable `services.displayManager.cosmic-greeter`.
3. WHERE the system76-scheduler optimization is desired, THE COSMIC_System_Module SHALL enable `services.system76-scheduler`.

### Requirement 4: Shared Home-Manager Configuration Extraction

**User Story:** As a NixOS user, I want shared home-manager configuration separated from DE-specific configuration, so that user-level settings are defined once and reused across all DE variants.

#### Acceptance Criteria

1. THE Shared_Home_Config SHALL contain all DE-agnostic home-manager settings from the current `hosts/max/home.nix`, including neovim, starship, zsh, git, kitty, GTK/Qt theming, cursor, XDG dirs, dconf, btop, direnv, gh, ghostty config, swappy config, wallpapers, and DE-agnostic user packages.
2. THE Shared_Home_Config SHALL NOT contain any Hyprland-specific imports (hyprland.nix, rofi, waybar, wlogout, swaync) or Hyprland-specific services (hypridle, swaylock).
3. WHEN a DE variant includes the Shared_Home_Config, THE DE variant SHALL receive all shared home-manager settings without duplication.

### Requirement 5: Hyprland Home Module

**User Story:** As a Hyprland user, I want Hyprland-specific home-manager configuration in its own module, so that it can be included only when building the Hyprland variant.

#### Acceptance Criteria

1. THE Hyprland_Home_Module SHALL import the Hyprland-specific config files: `hyprland.nix`, `rofi/rofi.nix`, `rofi/config-long.nix`, `swaync.nix`, `waybar.nix`, and `wlogout.nix`.
2. THE Hyprland_Home_Module SHALL configure the `hypridle` service with the current Hyprland-specific idle settings (swaylock lock command, dpms via hyprctl).
3. THE Hyprland_Home_Module SHALL configure `swaylock` with the current settings.
4. THE Hyprland_Home_Module SHALL include the `list-hypr-bindings` script in `home.packages`.
5. THE Hyprland_Home_Module SHALL include the `wlogout` icons in `home.file.".config/wlogout/icons"`.

### Requirement 6: COSMIC Home Module

**User Story:** As a NixOS user, I want a COSMIC DE home-manager module, so that future COSMIC-specific user configuration has a dedicated location.

#### Acceptance Criteria

1. THE COSMIC_Home_Module SHALL exist as a valid Home_Manager_Module that can be imported without error.
2. THE COSMIC_Home_Module SHALL serve as a placeholder for future COSMIC-specific home-manager configuration.

### Requirement 7: Multiple Flake Configurations

**User Story:** As a NixOS user, I want multiple `nixosConfigurations` in my flake, so that I can build and switch between DE variants using `nixos-rebuild switch --flake .#<config-name>`.

#### Acceptance Criteria

1. THE Flake SHALL define a `nixosConfigurations."max-hyprland"` attribute that combines the Shared_System_Config, the Hyprland_System_Module, the Shared_Home_Config, and the Hyprland_Home_Module.
2. THE Flake SHALL define a `nixosConfigurations."max-cosmic"` attribute that combines the Shared_System_Config, the COSMIC_System_Module, the Shared_Home_Config, and the COSMIC_Home_Module.
3. THE Flake SHALL preserve the existing `devShells` configuration unchanged.
4. WHEN the user runs `nixos-rebuild switch --flake .#max-hyprland`, THE Flake SHALL produce a NixOS system with Hyprland as the desktop environment.
5. WHEN the user runs `nixos-rebuild switch --flake .#max-cosmic`, THE Flake SHALL produce a NixOS system with COSMIC as the desktop environment.

### Requirement 8: Backward Compatibility

**User Story:** As a NixOS user, I want the refactored Hyprland configuration to produce an equivalent system to the current configuration, so that the refactoring does not break my existing setup.

#### Acceptance Criteria

1. THE `max-hyprland` configuration SHALL produce a system functionally equivalent to the current `max` configuration.
2. THE Flake SHALL retain a `nixosConfigurations."max"` attribute that is an alias for `max-hyprland`, so that existing rebuild commands continue to work.

### Requirement 9: Extensibility for Future DEs

**User Story:** As a NixOS user, I want the module structure to be easy to extend, so that adding a new DE in the future requires only creating new DE_System_Module and DE_Home_Module files and a new flake configuration entry.

#### Acceptance Criteria

1. WHEN a new DE is added, THE Flake SHALL require only a new `nixosConfigurations` entry that combines the Shared_System_Config, the new DE_System_Module, the Shared_Home_Config, and the new DE_Home_Module.
2. THE module structure SHALL keep DE-specific system config and DE-specific home config in separate, clearly named files or directories.
