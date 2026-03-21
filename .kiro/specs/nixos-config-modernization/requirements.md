# Requirements Document

## Introduction

Modernize the NixOS flake-based configuration for host `max` by replacing deprecated, archived, or mismatched packages with their current recommended alternatives, removing unnecessary flake inputs and cache configuration, and simplifying configuration patterns where NixOS now provides built-in options. The goal is to reduce maintenance burden, improve Wayland compatibility, and align with current NixOS ecosystem best practices.

## Glossary

- **Flake_Configuration**: The NixOS flake defined in `flake.nix`, including all inputs, outputs, and module composition
- **Rofi_Module**: The rofi application launcher configuration in `config/rofi/rofi.nix`
- **Hyprland_System_Module**: The Hyprland system-level configuration in `hosts/max/hyprland-system.nix`
- **Hyprland_Home_Module**: The Hyprland home-manager configuration in `hosts/max/hyprland-home.nix`
- **Wlogout_Module**: The wlogout power menu configuration in `config/wlogout.nix`
- **Packages_Module**: The system packages list in `hosts/max/packages.nix`
- **System_Config_Module**: The shared system configuration in `hosts/max/config.nix`
- **Home_Config_Module**: The shared home-manager configuration in `hosts/max/home.nix`
- **COSMIC_System_Module**: The COSMIC desktop environment configuration in `hosts/max/cosmic-system.nix`
- **Hypridle_Service**: The idle management service configured in the Hyprland_Home_Module
- **Hyprlock**: The Hyprland-native screen locker, replacing swaylock
- **nixfmt-rfc-style**: The official Nix formatter implementing RFC 166, successor to the legacy `nixfmt` package

## Requirements

### Requirement 1: Replace Rofi X11 Package with Wayland-Native Package

**User Story:** As a Hyprland user, I want the rofi launcher to use the Wayland-native package, so that it runs natively on my Wayland compositor without X11 compatibility overhead.

#### Acceptance Criteria

1. THE Rofi_Module SHALL use `pkgs.rofi-wayland` as the rofi package
2. WHEN the Rofi_Module is evaluated, THE Rofi_Module SHALL preserve all existing `extraConfig`, theme, and keybinding settings without modification
3. WHEN the rofi launcher is invoked on Hyprland, THE Rofi_Module SHALL provide a rofi instance that renders using the Wayland display protocol

### Requirement 2: Remove Unnecessary Hyprland Cachix Configuration

**User Story:** As a NixOS maintainer, I want to remove the unused Hyprland cachix substituter, so that the nix configuration does not reference an unnecessary binary cache.

#### Acceptance Criteria

1. THE Hyprland_System_Module SHALL NOT include `hyprland.cachix.org` in `nix.settings.substituters`
2. THE Hyprland_System_Module SHALL NOT include the Hyprland cachix public key in `nix.settings.trusted-public-keys`
3. WHEN the Hyprland_System_Module is evaluated, THE Hyprland_System_Module SHALL retain all non-cache-related configuration (greetd, portal, session variables)

### Requirement 3: Replace Legacy nixfmt with nixfmt-rfc-style

**User Story:** As a Nix developer, I want to use the official RFC 166 formatter, so that my Nix code follows the community-standard formatting convention.

#### Acceptance Criteria

1. THE Packages_Module SHALL include `nixfmt-rfc-style` in the system packages list
2. THE Packages_Module SHALL NOT include the legacy `nixfmt` package
3. WHEN `nixfmt-rfc-style` is invoked, THE Packages_Module SHALL provide a formatter that implements RFC 166 formatting rules

### Requirement 4: Replace swaylock with Hyprlock

**User Story:** As a Hyprland user, I want to use hyprlock as my screen locker, so that I have a lock screen that is native to the Hyprland ecosystem and supports built-in fingerprint authentication.

#### Acceptance Criteria

1. THE Hyprland_Home_Module SHALL configure `programs.hyprlock` with enable set to true
2. THE Hyprland_Home_Module SHALL translate the existing swaylock color scheme (background `2f302f`, ring `4b9bac`, key-highlight `6998b4`, text `e9eaeb`) into the equivalent hyprlock configuration format
3. THE Hyprland_Home_Module SHALL NOT contain any `programs.swaylock` configuration
4. WHEN the Hypridle_Service triggers a lock event, THE Hypridle_Service SHALL invoke `hyprlock` instead of `swaylock` in `lock_cmd`
5. WHEN a timeout listener triggers in the Hypridle_Service, THE Hypridle_Service SHALL invoke `hyprlock` instead of `swaylock`
6. THE Wlogout_Module SHALL invoke `hyprlock` instead of `swaylock` in the suspend, lock, and hibernate actions
7. THE Hyprland_System_Module SHALL NOT contain `security.pam.services.swaylock` configuration
8. THE Hyprland_Home_Module SHALL enable fingerprint authentication in the hyprlock configuration via `enable_fingerprint`

### Requirement 5: Evaluate and Simplify COSMIC Flake Dependency

**User Story:** As a NixOS maintainer, I want to use COSMIC from nixpkgs-unstable if available, so that I can reduce the number of external flake inputs and simplify the configuration.

#### Acceptance Criteria

1. WHEN `services.desktopManager.cosmic.enable` is available in nixpkgs-unstable without the external `nixos-cosmic` flake, THE Flake_Configuration SHALL remove the `nixos-cosmic` input from `flake.nix`
2. WHEN the `nixos-cosmic` input is removed, THE Flake_Configuration SHALL remove `nixos-cosmic.nixosModules.default` from the `max-cosmic` system modules list
3. WHEN the `nixos-cosmic` input is removed, THE COSMIC_System_Module SHALL continue to enable COSMIC via `services.desktopManager.cosmic.enable` using only nixpkgs
4. IF `services.desktopManager.cosmic.enable` is NOT available in nixpkgs-unstable without the external flake, THEN THE Flake_Configuration SHALL retain the `nixos-cosmic` input unchanged

### Requirement 6: Replace Archived arc-theme with Maintained Alternative

**User Story:** As a desktop user, I want to use an actively maintained GTK theme, so that my theme remains compatible with current GTK versions and receives bug fixes.

#### Acceptance Criteria

1. THE Home_Config_Module SHALL configure the GTK theme to use `adw-gtk3-dark` from the `adw-gtk3` package as a replacement for `arc-theme`
2. THE Home_Config_Module SHALL NOT reference `arc-theme` in the GTK theme configuration or in `home.packages`
3. WHEN the GTK theme is applied, THE Home_Config_Module SHALL preserve the dark theme preference across GTK3 and GTK4 applications

### Requirement 7: Simplify AppImage binfmt Registration

**User Story:** As a NixOS maintainer, I want to use the built-in AppImage binfmt option, so that the configuration is simpler and maintained upstream.

#### Acceptance Criteria

1. THE System_Config_Module SHALL use `programs.appimage.binfmt = true` to enable AppImage support
2. THE System_Config_Module SHALL NOT contain a manual `boot.binfmt.registrations.appimage` block
3. WHEN an AppImage binary is executed, THE System_Config_Module SHALL provide binfmt registration that launches AppImage files correctly

### Requirement 8: Normalize Formatting Across All Nix Files

**User Story:** As a NixOS maintainer, I want consistent formatting across all `.nix` files, so that the codebase is uniform and easier to review.

#### Acceptance Criteria

1. WHEN `nixfmt-rfc-style` is run on any `.nix` file in the repository, THE file SHALL conform to RFC 166 formatting rules
2. THE formatting pass SHALL NOT alter the semantic meaning or evaluation result of any Nix expression
3. THE formatting pass SHALL normalize indentation to the style prescribed by `nixfmt-rfc-style` across all `.nix` files in the repository
