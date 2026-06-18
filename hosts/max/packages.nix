{ pkgs }:

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
  nh
  libz
  lazygit
  mongodb-compass
  awscli
  podman-compose
  podman-tui
  git-extras
  git-lfs
  diff-so-fancy
  jetbrains-toolbox
  ghostty
  nushell
  ollama
  code-cursor
  insomnia
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
  llama-cpp
  pi-coding-agent
  lmstudio
  duckdb
  opencode

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
  docker-compose
  sqlite
  postgresql
  redis

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
  appimage-run
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
  obsidian
  mpv

  # Wayland/Desktop Environment Tools
  lxqt.lxqt-policykit
  v4l-utils
  swappy
  hyprpicker
  swaynotificationcenter
  swww
  grim
  slurp
  tuigreet
  imv

  # Web Browsers
  brave

  # Communication Tools
  slack
  teams-for-linux
]
