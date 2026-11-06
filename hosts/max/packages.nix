{ pkgs }:

let
  # appimage-run patched with systemd + unzip inside the FHS sandbox
  # (see the long note below for why both are needed).
  appimageRun = pkgs.appimage-run.override {
    extraPkgs = p: [
      p.systemd
      p.unzip
    ];
  };

  # Launcher wrapper for KiroCrew: sources the git-ignored secret file so
  # GITEA_PAT (and any future gateway secrets) reach the AppImage's environment
  # regardless of how it is started — terminal, .desktop, or file-manager
  # "open with". The secret value lives ONLY in ~/.config/secrets/kiro-crew.env
  # (chmod 600, never in git / the Nix store); this wrapper references the path.
  #
  # Detaches from the launching shell so quitting the terminal (SIGHUP) does
  # NOT take the gateway down: `setsid` starts a new session with no controlling
  # terminal, stdio is redirected to a log, and `&` + `disown` returns the
  # prompt immediately. Works the same from a .desktop / file-manager launch
  # (there is simply no terminal to detach from). Pass KIROCREW_FG=1 to run it
  # in the foreground instead (e.g. to watch its output while debugging).
  kirocrew = pkgs.writeShellScriptBin "kirocrew" ''
    secret="$HOME/.config/secrets/kiro-crew.env"
    [ -f "$secret" ] && . "$secret"

    if [ -n "''${KIROCREW_FG:-}" ]; then
      exec ${appimageRun}/bin/appimage-run "$HOME/KiroCrew-x86_64.AppImage" "$@"
    fi

    logdir="''${XDG_STATE_HOME:-$HOME/.local/state}/kirocrew"
    mkdir -p "$logdir"
    ${pkgs.util-linux}/bin/setsid -f \
      ${appimageRun}/bin/appimage-run "$HOME/KiroCrew-x86_64.AppImage" "$@" \
      >>"$logdir/launch.log" 2>&1 < /dev/null
    echo "KiroCrew launched (detached). Log: $logdir/launch.log"
  '';
in
with pkgs;
[
  # Development Tools
  git
  ripgrep
  jq
  bat
  meson
  pkg-config
  nixfmt
  ruff # Python linter + formatter (Rust binary, global on PATH)
  ast-grep # structural (AST) code search / lint / rewrite - custom rules for the dev-loop gate (Tech Radar Vol 35 #73)
  vale # prose linter for specs / ADRs / docs, CI-enforceable (Tech Radar Vol 35 #101)
  nh
  libz
  lazygit
  awscli2
  podman-compose
  podman-tui
  git-extras
  git-lfs
  diff-so-fancy
  jetbrains-toolbox
  ghostty
  nushell
  databricks-cli
  kooha
  clickhouse
  kiro
  kiro-cli
  nodejs
  tsx
  uv
  rustup
  neovim
  duckdb
  dolt
  # opencode  # removed 2026-11-04: upstream nixpkgs node_modules FOD hash mismatch breaks the build; not used for work. Re-add when fixed upstream.

  # Base dev libraries (system-wide so devbox/direnv layers on top)
  gcc
  gnumake
  cmake
  openssl
  openssl.dev
  pkg-config
  python3
  python3Packages.pip
  python3Packages.virtualenv
  go
  sqlite

  # System Utilities
  wget
  fprintd
  killall
  eza
  unzip
  unrar
  tree
  ncdu
  duf
  wl-clipboard
  ydotool
  brightnessctl
  lshw
  inxi
  socat
  # appimage-run with systemd + unzip inside the FHS sandbox.
  # KiroCrew (AppImage) verifies kiro-cli by running it inside a
  # `systemd-run --user --scope` cgroup wrapper, and resolves that wrapper ONLY
  # via /bin:/usr/bin — which inside the appimage FHS is the FHS rootfs, not the
  # host. Without systemd-run there, verification always fails and the setup
  # gate falls back to the official installer, which then aborts on missing
  # unzip. Both live here so the sandbox has them. (Defined in the `let` above
  # as `appimageRun` so the `kirocrew` wrapper reuses the same patched build.)
  appimageRun
  kirocrew # KiroCrew launcher: sources ~/.config/secrets/kiro-crew.env then runs the AppImage
  file-roller
  yad
  zoxide
  gnupg
  ktailctl
  devbox
  steam-run # FHS escape hatch for stubborn binaries

  # GTK and Theme Support
  dconf
  gsettings-desktop-schemas
  adwaita-icon-theme

  # System Monitoring
  htop
  atop
  radeontop
  clinfo
  lm_sensors

  # Networking Tools
  networkmanagerapplet
  pciutils
  tailscale

  # Multimedia Tools
  pavucontrol
  playerctl
  # Pinned to electron_42: Electron 43 (2026-11-03 nixpkgs bump) dropped a
  # `webFrame` renderer API Obsidian still calls, crashing it on launch.
  # electron_42 keeps that API; permittedInsecurePackages in config.nix allows
  # it. Drop this override once upstream obsidian builds against electron >=43.
  (obsidian.override { electron = electron_42; })
  mpv

  # Wayland/Desktop Environment Tools
  lxqt.lxqt-policykit
  v4l-utils
  swappy
  hyprpicker
  swaynotificationcenter
  awww
  grim
  slurp
  tuigreet
  imv

  # Web Browsers
  brave
  firefox # second browser; use the Multi-Account Containers add-on for simultaneous AWS logins

  # Communication Tools
  slack
  teams-for-linux
  signal-desktop

  # Office / Productivity
  libreoffice # replaces the removed LibreOffice flatpak
]
