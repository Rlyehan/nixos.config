# Implementation Plan: Multi-DE Support

## Overview

Refactor the NixOS flake to support multiple desktop environments by extracting DE-specific config from shared files, creating per-DE modules (Hyprland + COSMIC), and wiring them together via a `mkHost` helper in `flake.nix`. Each task builds incrementally — shared config is cleaned first, then DE modules are created, then flake.nix is updated to compose everything.

## Tasks

- [x] 1. Extract Hyprland-specific system config into `hosts/max/hyprland-system.nix`
  - [x] 1.1 Create `hosts/max/hyprland-system.nix` with all Hyprland-specific system configuration
    - Move `programs.hyprland = { enable = true; withUWSM = true; }` from `config.nix`
    - Move `environment.sessionVariables.NIXOS_OZONE_WL = "1"` from `config.nix`
    - Move `services.greetd` block (tuigreet + `uwsm start hyprland.desktop`) from `config.nix`
    - Move `xdg.portal.configPackages` entry for `xdg-desktop-portal-hyprland` from `config.nix`
    - Move `security.pam.services.swaylock` and `security.pam.services.swaylock.fprintAuth` from `config.nix`
    - Move Hyprland cachix substituter and trusted public key from `nix.settings` in `config.nix`
    - Module should take `{ pkgs, username, ... }` args and return the extracted attribute set
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 1.2 Remove Hyprland-specific system configuration from `hosts/max/config.nix`
    - Remove `programs.hyprland` block
    - Remove `environment.sessionVariables.NIXOS_OZONE_WL`
    - Remove `services.greetd` block
    - Remove `xdg-desktop-portal-hyprland` from `xdg.portal.configPackages`
    - Remove `security.pam.services.swaylock` entries
    - Remove Hyprland cachix substituter and key from `nix.settings`
    - Keep all shared config intact: boot, networking, locale, fonts, hardware, security/polkit, virtualization, pipewire, printing, bluetooth, flatpak, openssh, auto-cpufreq, etc.
    - Keep `xdg.portal` block but without the hyprland-specific `configPackages` entry
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Extract Hyprland-specific home config into `hosts/max/hyprland-home.nix`
  - [x] 2.1 Create `hosts/max/hyprland-home.nix` with all Hyprland-specific home-manager configuration
    - Move imports: `config/hyprland.nix`, `config/rofi/rofi.nix`, `config/rofi/config-long.nix`, `config/swaync.nix`, `config/waybar.nix`, `config/wlogout.nix`
    - Move `services.hypridle` block
    - Move `programs.swaylock` block
    - Move `home.file.".config/wlogout/icons"` block
    - Move `list-hypr-bindings` script from `home.packages`
    - Module should take `{ pkgs, host, ... }` args
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 2.2 Remove Hyprland-specific home configuration from `hosts/max/home.nix`
    - Remove Hyprland-specific imports (hyprland.nix, rofi, swaync, waybar, wlogout)
    - Remove `services.hypridle` block
    - Remove `programs.swaylock` block
    - Remove `home.file.".config/wlogout/icons"` block
    - Remove `list-hypr-bindings` script from `home.packages`
    - Keep all shared home config: neovim, starship, zsh, git, kitty, GTK/Qt theming, cursor, XDG dirs, dconf, btop, direnv, gh, ghostty, swappy, wallpapers, and non-Hyprland packages/scripts
    - _Requirements: 4.1, 4.2_

- [x] 3. Checkpoint - Verify extraction completeness
  - Ensure all Hyprland-specific config has been moved out of shared files and into the new DE modules
  - Ensure shared files contain no Hyprland references
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Create COSMIC DE modules
  - [x] 4.1 Create `hosts/max/cosmic-system.nix` with COSMIC system configuration
    - Enable `services.desktopManager.cosmic`
    - Enable `services.displayManager.cosmic-greeter`
    - Enable `services.system76-scheduler`
    - Module should take `{ ... }` args
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 4.2 Create `hosts/max/cosmic-home.nix` as a placeholder home-manager module
    - Create a valid but empty home-manager module `{ ... }: {}`
    - _Requirements: 6.1, 6.2_

- [x] 5. Refactor `flake.nix` with `mkHost` helper and multiple configurations
  - [x] 5.1 Add `nixos-cosmic` flake input to `flake.nix`
    - Add `nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic"` to inputs
    - Add appropriate `follows` for nixpkgs if needed
    - _Requirements: 3.1_

  - [x] 5.2 Create `mkHost` helper function and define `nixosConfigurations`
    - Define `mkHost = { systemModules, homeModules }:` that wraps `nixpkgs.lib.nixosSystem` with shared `specialArgs`, shared system module (`config.nix`), home-manager setup, and shared home module (`home.nix`), then appends the DE-specific `systemModules` and `homeModules`
    - Define `nixosConfigurations."max-hyprland"` using `mkHost` with `hyprland-system.nix` and `hyprland-home.nix`
    - Define `nixosConfigurations."max-cosmic"` using `mkHost` with `cosmic-system.nix` and `cosmic-home.nix`
    - Define `nixosConfigurations."max"` as an alias for `max-hyprland`
    - Preserve existing `devShells` configuration unchanged
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.2, 9.1_

- [x] 6. Checkpoint - Verify full flake evaluation
  - Run `nix flake check` or `nix eval .#nixosConfigurations.max-hyprland` to verify the Hyprland config evaluates
  - Run `nix eval .#nixosConfigurations.max-cosmic` to verify the COSMIC config evaluates
  - Run `nix eval .#nixosConfigurations.max` to verify the backward-compat alias works
  - Verify `devShells` still evaluates correctly
  - Ensure all tests pass, ask the user if questions arise.
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2_

- [ ]* 7. Write property tests for configuration correctness
  - [ ]* 7.1 Write property test: shared config excludes DE-specific attributes
    - **Property 1: Shared config excludes all DE-specific attributes**
    - Enumerate Hyprland-specific attribute paths (`programs.hyprland`, `services.greetd`, `security.pam.services.swaylock`, hyprland cachix, `NIXOS_OZONE_WL`, `services.hypridle`, `programs.swaylock`)
    - Verify none are set in the shared `config.nix` / `home.nix` evaluation
    - **Validates: Requirements 1.3, 4.2**

  - [ ]* 7.2 Write property test: shared configuration identical across DE variants
    - **Property 2: Shared configuration is identical across DE variants**
    - Enumerate shared attribute paths (boot, networking, locale, fonts, neovim, starship, zsh, git, kitty, GTK/Qt, cursor, XDG, dconf, btop, direnv, gh, ghostty, swappy, wallpapers)
    - Evaluate both `max-hyprland` and `max-cosmic` and assert equality for each path
    - **Validates: Requirements 1.4, 4.3**

  - [ ]* 7.3 Write property test: backward compatibility of refactored Hyprland config
    - **Property 3: Backward compatibility — refactored Hyprland config equivalence**
    - Compare pre-refactoring `max` attribute values with post-refactoring `max-hyprland` values
    - **Validates: Requirements 8.1**

- [ ] 8. Final checkpoint - Full build verification
  - Ensure all tests pass, ask the user if questions arise.
  - Verify `nix build .#nixosConfigurations.max-hyprland.config.system.build.toplevel` succeeds
  - Verify `nix build .#nixosConfigurations.max-cosmic.config.system.build.toplevel` succeeds
  - _Requirements: 7.4, 7.5, 8.1, 9.1, 9.2_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- The refactoring is purely structural — no new Hyprland functionality is added
- COSMIC module is minimal (system services + placeholder home module)
- The `mkHost` helper keeps flake.nix DRY and makes adding future DEs trivial
