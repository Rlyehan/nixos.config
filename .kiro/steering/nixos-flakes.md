---
inclusion: fileMatch
fileMatchPattern: "**/*.nix"
---

# NixOS + Flakes Development Guide

This workspace is a NixOS flake-based system configuration for host `max`, using Hyprland and COSMIC desktop environments with Home Manager integration.

## Workspace Structure

- `flake.nix` — root flake with `mkHost` helper, nixpkgs unstable, home-manager, nixos-cosmic inputs
- `hosts/max/` — host-specific system and home configs, per-DE modules (hyprland-system/home, cosmic-system/home)
- `config/` — shared config modules (waybar, rofi, starship, zsh, swaync, colors, wallpapers)
- `scripts/` — utility scripts as Nix derivations

## Flake Conventions

### Input Hygiene

- Pin `nixpkgs` to `nixos-unstable` (or a specific commit for stability)
- Use `inputs.X.inputs.nixpkgs.follows = "nixpkgs"` for all transitive deps to get a single nixpkgs eval and smaller closure
- Always commit `flake.lock` — never gitignore it
- Update one input at a time when debugging regressions: `nix flake update <input-name>`

### Output Structure

- `nixosConfigurations` keyed by `<host>-<de>` pattern (e.g., `max-hyprland`, `max-cosmic`)
- Default config aliases to the primary DE: `"max" = configs."max-hyprland"`
- `devShells` for project-specific tooling
- Home Manager integrated as NixOS module via `home-manager.nixosModules.home-manager`

### Module Composition

- Small, focused modules — one concern per file
- System-level modules in `hosts/<host>/` (hardware, users, packages, DE-specific system config)
- Home-level modules split between `hosts/<host>/` (DE-specific home) and `config/` (shared programs)
- Use `specialArgs` / `extraSpecialArgs` to pass `system`, `inputs`, `username`, `host` through the module tree
- `useGlobalPkgs = true` and `useUserPackages = true` for Home Manager to share the system nixpkgs instance

## Key `lib` Functions

| Function | Use |
|---|---|
| `mkIf` | Conditional config blocks — guards entire attrsets |
| `mkMerge` | Combine multiple config fragments in one module |
| `mkDefault` | Set a value that downstream modules can override (priority 1000) |
| `mkForce` | Override everything (priority 50) — use sparingly |
| `mkEnableOption` | Shorthand for a boolean option defaulting to `false` |
| `mkPackageOption` | Declare a package option with proper defaults and type |
| `mkOption` | Full option declaration with type, default, description |

## Module Option Patterns

When creating reusable modules, expose behavior through options:

```nix
options.my.services.myapp = {
  enable = lib.mkEnableOption "myapp service";
  port = lib.mkOption {
    type = lib.types.port;
    default = 8080;
    description = "Listen port for myapp";
  };
};
config = lib.mkIf config.my.services.myapp.enable {
  systemd.services.myapp = { ... };
};
```

## Overlay Patterns

```nix
# In flake outputs
overlays.default = final: prev: {
  myapp = final.callPackage ./pkgs/myapp { };
};
```

- Apply overlays via `nixpkgs.overlays` in the host config, not inline in flake.nix
- Prefer `final` (self) for deps that may also be overlaid; `prev` (super) for the original
- When adding overlay inputs, use `follows` to share the parent nixpkgs:

```nix
inputs = {
  some-overlay.url = "github:owner/some-overlay";
  some-overlay.inputs.nixpkgs.follows = "nixpkgs";
};
```

- Apply in host config:

```nix
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      some-overlay.overlays.default
      # Inline overlay
      (final: prev: {
        myPackage = prev.myPackage.override { ... };
      })
    ];
  };
in ...
```

## Unfree Package Handling

This workspace uses `nixpkgs.config.allowUnfree = true` globally. Other approaches:

- Per-package: `config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "specific-package" ]`
- For `nix develop` with unfree: `NIXPKGS_ALLOW_UNFREE=1 nix develop --impure`
- Note: `config.allowUnfree` in flake.nix does NOT propagate to `nix develop`

## Rebuild Workflow

```bash
# Check flake validity and run all checks
nix flake check

# Build without switching (safe test)
nixos-rebuild build --flake .#max

# Ephemeral activation (reverts on reboot)
sudo nixos-rebuild test --flake .#max

# Activate and set as boot default
sudo nixos-rebuild switch --flake .#max

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

## Flake Management Commands

```bash
# Update all inputs
nix flake update

# Update specific input only
nix flake update home-manager

# Lock without updating (create missing entries)
nix flake lock

# Show flake outputs
nix flake show

# Show flake metadata (inputs, revisions)
nix flake metadata

# Evaluate a specific output
nix eval .#nixosConfigurations.max.config.system.stateVersion

# Enter dev shell
nix develop

# Run command in dev shell without entering it
nix develop -c <command>

# Build a specific package
nix build .#packageName
```

## devShell and Direnv Patterns

This workspace uses direnv with nix-direnv for automatic shell activation. The `.envrc` should contain:

```bash
use flake
```

devShell pattern:

```nix
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [ /* packages */ ];

  # Static env vars
  DATABASE_URL = "postgres://localhost/dev";

  # Dynamic env vars
  shellHook = ''
    export PROJECT_ROOT="$(pwd)"
  '';
};
```

For native C/C++ dependencies:

```nix
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [ openssl ];
  shellHook = ''
    export C_INCLUDE_PATH="${pkgs.openssl.dev}/include:$C_INCLUDE_PATH"
    export LIBRARY_PATH="${pkgs.openssl.out}/lib:$LIBRARY_PATH"
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
  '';
};
```

## Garbage Collection and Store Maintenance

This workspace has automatic weekly GC configured (`--delete-older-than 7d`). Manual commands:

```bash
# Delete old generations and run GC
sudo nix-collect-garbage --delete-older-than 14d

# Store-level GC only (does not delete generations)
nix store gc

# Optimize store (deduplicate)
nix store optimise
```

## Anti-Patterns to Avoid

| Don't | Do Instead |
|---|---|
| `nix-env -iA` for system packages | Declare in `environment.systemPackages` or Home Manager `home.packages` |
| `inputs.nixpkgs.url = "nixpkgs"` (unpinned) | `url = "github:NixOS/nixpkgs/nixos-unstable"` |
| Monolithic `configuration.nix` (500+ lines) | Split into focused modules per concern |
| Import-from-derivation (IFD) at eval time | Pre-generate files or use `builtins.readFile` |
| Manual edits to `/etc/*` on NixOS | Declare via `environment.etc` or service options |
| `mkForce` to fix option conflicts | Understand merge precedence; restructure modules |
| Disabling the firewall "temporarily" | Add explicit `networking.firewall.allowedTCPPorts` |
| `lib.mdDoc` for option descriptions | Removed in 24.11 — Markdown is now the default |
| Pushing to a flake input repo and expecting rebuild to pick it up | Always `nix flake update <input>` first — builds use the locked revision |

## Troubleshooting

### "unexpected argument" Error
All inputs must be listed in the outputs function signature:
```nix
# Wrong — missing inputs
outputs = { self, nixpkgs }: ...

# Right
outputs = { self, nixpkgs, home-manager, nixos-cosmic, ... }: ...
```

### Duplicate Nixpkgs Downloads
Use `follows` to chain all inputs to a single nixpkgs source.

### Overlay Not Applied
Ensure overlay is in the `overlays` list when importing nixpkgs:
```nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [ my-overlay.overlays.default ];
};
```

### Hash Mismatch
Re-fetch with `nix-prefetch-url` and update the hash. Hashes change when upstream updates binaries at the same URL.
```bash
nix-prefetch-url https://example.com/file
nix hash to-sri --type sha256 <base32-hash>
```

### Flake Purity
Flakes cannot access files outside the flake directory unless tracked by git. If a file isn't showing up, make sure it's `git add`-ed.

## Useful References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [nix.dev](https://nix.dev/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Packages Search](https://search.nixos.org/packages)
- [zero-to-nix.com](https://zero-to-nix.com/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
