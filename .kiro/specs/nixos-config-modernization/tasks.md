# Implementation Plan: NixOS Config Modernization

## Overview

Incrementally modernize the NixOS flake configuration for host `max` by applying independent package swaps, configuration cleanups, and a final formatting pass. Each task targets specific module files and can be validated with `nixos-rebuild build`. Tasks are ordered so that each builds on the previous, with the formatting pass last to cover all changes.

## Tasks

- [x] 1. Replace rofi with rofi-wayland
  - [x] 1.1 Swap rofi package in `config/rofi/rofi.nix`
    - Change `pkgs.rofi` to `pkgs.rofi-wayland` in `programs.rofi.package`
    - Preserve all existing `extraConfig`, theme, and keybinding settings unchanged
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Remove Hyprland cachix configuration
  - [x] 2.1 Remove cachix entries from `hosts/max/hyprland-system.nix`
    - Remove `nix.settings.substituters` entry for `hyprland.cachix.org`
    - Remove the corresponding public key from `nix.settings.trusted-public-keys`
    - Remove the entire `nix.settings` block from this module if it only contains cachix config
    - Retain all non-cache config (greetd, portal, session variables, PAM)
    - _Requirements: 2.1, 2.2, 2.3_

- [x] 3. Replace nixfmt with nixfmt-rfc-style
  - [x] 3.1 Swap formatter package in `hosts/max/packages.nix`
    - Replace `nixfmt` with `nixfmt-rfc-style` in the packages list
    - _Requirements: 3.1, 3.2_

- [x] 4. Replace swaylock with hyprlock
  - [x] 4.1 Add hyprlock configuration in `hosts/max/hyprland-home.nix`
    - Remove the entire `programs.swaylock` block
    - Add `programs.hyprlock` block with `enable = true`
    - Translate existing swaylock color scheme into hyprlock settings:
      - background: `rgb(2f302f)`
      - outer_color (ring): `rgb(4b9bac)`
      - inner_color: `rgb(2f302f)`
      - font_color (text): `rgb(e9eaeb)`
      - check_color (key highlight): `rgb(6998b4)`
    - Enable fingerprint auth via `auth.fingerprint.enabled = true`
    - _Requirements: 4.1, 4.2, 4.3, 4.8_

  - [x] 4.2 Update hypridle lock commands in `hosts/max/hyprland-home.nix`
    - Change `lock_cmd` from `"swaylock"` to `"hyprlock"`
    - Change timeout listener `on-timeout` from `"swaylock"` to `"hyprlock"`
    - _Requirements: 4.4, 4.5_

  - [x] 4.3 Update wlogout actions in `config/wlogout.nix`
    - Replace `swaylock` with `hyprlock` in suspend, lock, and hibernate actions
    - _Requirements: 4.6_

  - [ ]* 4.4 Write property test for wlogout actions (Property 1)
    - **Property 1: Wlogout actions reference hyprlock exclusively**
    - Parse all wlogout layout entries and assert no action contains the string `swaylock`
    - **Validates: Requirement 4.6**

  - [x] 4.5 Remove swaylock PAM config from `hosts/max/hyprland-system.nix`
    - Remove `security.pam.services.swaylock` block
    - _Requirements: 4.7_

- [x] 5. Checkpoint — Verify Hyprland configuration builds
  - Ensure all tests pass, ask the user if questions arise.
  - Run `nixos-rebuild build --flake .#max-hyprland` to validate changes from tasks 1–4

- [x] 6. Evaluate COSMIC flake dependency
  - [x] 6.1 Check if COSMIC is available in nixpkgs-unstable
    - Evaluate whether `services.desktopManager.cosmic.enable` exists in nixpkgs without the external `nixos-cosmic` flake
    - If available: remove `nixos-cosmic` input from `flake.nix`, remove `nixos-cosmic.nixosModules.default` from `max-cosmic` modules, remove `nixos-cosmic` from outputs function signature
    - If not available: leave `nixos-cosmic` input unchanged, document the finding
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 7. Replace arc-theme with adw-gtk3-dark
  - [x] 7.1 Swap GTK theme in `hosts/max/home.nix`
    - Change `gtk.theme.name` to `"adw-gtk3-dark"` and `gtk.theme.package` to `pkgs.adw-gtk3`
    - Remove any `pkgs.arc-theme` references from `home.packages`
    - Preserve existing `gtk3.extraConfig` and `gtk4.extraConfig` dark theme preferences
    - Preserve `dconf.settings` color-scheme preference
    - _Requirements: 6.1, 6.2, 6.3_

- [x] 8. Simplify AppImage binfmt registration
  - [x] 8.1 Replace manual binfmt block in `hosts/max/config.nix`
    - Remove the entire `boot.binfmt.registrations.appimage` block
    - Add `programs.appimage.binfmt = true;`
    - _Requirements: 7.1, 7.2, 7.3_

- [x] 9. Checkpoint — Verify full configuration builds
  - Ensure all tests pass, ask the user if questions arise.
  - Run `nixos-rebuild build --flake .#max-hyprland` and `nixos-rebuild build --flake .#max-cosmic` to validate all changes

- [x] 10. Run nixfmt-rfc-style across all Nix files
  - [x] 10.1 Format all `.nix` files with nixfmt-rfc-style
    - Run `nixfmt-rfc-style` on all `.nix` files in the repository: `flake.nix`, `hosts/max/*.nix`, `config/**/*.nix`, `scripts/*.nix`
    - This must be the final code change to cover all prior modifications
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ]* 10.2 Write property test for formatting idempotence (Property 2)
    - **Property 2: Formatting idempotence**
    - For each `.nix` file, run `nixfmt-rfc-style` and assert output equals input
    - **Validates: Requirements 8.1**

- [x] 11. Final checkpoint — Verify everything builds and is formatted
  - Ensure all tests pass, ask the user if questions arise.
  - Run `nixos-rebuild build --flake .#max-hyprland` and `nixos-rebuild build --flake .#max-cosmic` for final validation

## Notes

- Tasks marked with `*` are optional and can be skipped for faster completion
- Each task references specific acceptance criteria from the requirements document
- The COSMIC flake evaluation (task 6) is conditional — the outcome depends on nixpkgs-unstable state
- Formatting (task 10) is intentionally last so it covers all code changes
- Runtime verification (hyprlock locking, fingerprint auth, rofi rendering) requires `nixos-rebuild test` on the target machine
