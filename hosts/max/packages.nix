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
  nodejs_25
  tsx
  uv
  rustup
  neovim

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
