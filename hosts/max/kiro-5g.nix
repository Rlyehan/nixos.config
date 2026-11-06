# kiro-5g.nix — Home-manager module for 5gsystems Kiro setup
#
# What this does:
#   1. Ensures all runtime deps are on PATH (python3+pyyaml, git, curl, uv, etc.)
#   2. Declares a Nix-managed systemd user timer that runs update.sh daily
#      with an explicit PATH so it works unattended (no devShell needed).
#   3. Provides a convenience wrapper `kiro-setup` that clones/runs the installer.
#
# Usage:
#   imports = [ ./kiro-5g.nix ];
#
# After first `nixos-rebuild switch`, run `kiro-setup` to do the interactive install.
# Daily updates are then handled by the systemd timer automatically.
#
{ config, lib, pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pyyaml ]);

  # All runtime deps needed by kiro-setup.sh and update.sh
  kiroDeps = [
    pythonEnv
    pkgs.git
    pkgs.curl
    pkgs.uv
    pkgs.bash
    pkgs.coreutils
    pkgs.openssh # for git@git.noenv.eu clones
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
  ];

  depsPath = lib.makeBinPath kiroDeps;

  kiroRepo = "git@git.noenv.eu:ai-platform/kiro.git";
  kiroCloneDir = "$HOME/.5g-ai/knowledge/ai-platform/kiro";
  updateScript = "$HOME/.5g-ai/update.sh";

  # Wrapper: clone the repo if needed, then run the installer
  kiroSetupWrapper = pkgs.writeShellScriptBin "kiro-setup" ''
    set -euo pipefail
    export PATH="${depsPath}:$PATH"

    KIRO_DIR="${kiroCloneDir}"

    if [[ ! -d "$KIRO_DIR/.git" ]]; then
      echo "[kiro-setup] Cloning kiro repo..."
      mkdir -p "$(dirname "$KIRO_DIR")"
      git clone "${kiroRepo}" "$KIRO_DIR"
    fi

    # Pass all arguments through (e.g. --refresh, --update)
    exec bash "$KIRO_DIR/kiro-setup.sh" "$@"
  '';

in
{
  home.packages = kiroDeps ++ [
    kiroSetupWrapper
  ];

  # Nix-managed systemd user service + timer for daily updates.
  # This replaces the timer that kiro-setup.sh would write to
  # ~/.config/systemd/user/ — the Nix version guarantees PATH correctness.
  systemd.user.services."5g-ai-update" = {
    Unit = {
      Description = "5gsystems AI knowledge & powers updater";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = "PATH=${depsPath}";
      ExecStart = "${pkgs.bash}/bin/bash %h/.5g-ai/update.sh --non-interactive";
      # Don't fail the service if update.sh hasn't been deployed yet
      ExecCondition = "${pkgs.bash}/bin/bash -c 'test -x %h/.5g-ai/update.sh'";
    };
  };

  systemd.user.timers."5g-ai-update" = {
    Unit = {
      Description = "Daily 5gsystems AI knowledge update";
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min"; # avoid thundering herd if many devs
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
