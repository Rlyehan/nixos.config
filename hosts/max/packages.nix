{ pkgs }:

with pkgs; [
# Development Tools
vim
git
ripgrep
bat
meson
ninja
pkg-config
nixfmt-rfc-style
nh
zed-editor
lazygit
awscli
podman-compose
podman-tui
git-extras
git-lfs
diff-so-fancy
jetbrains-toolbox

#Languages
rustup #Rust
uv #Python
bun #JS

# System Utilities
wget
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

# System Monitoring
htop
lm_sensors

# Networking Tools
networkmanagerapplet
pciutils
tailscale

# Virtualization Tools
libvirt
virt-viewer

# Multimedia Tools
mpv
pavucontrol
playerctl
tidal-hifi


# Wayland/Desktop Environment Tools
lxqt.lxqt-policykit
v4l-utils
swappy
hyprpicker
swaynotificationcenter
swww
grim
slurp
greetd.tuigreet
imv

# Web Browsers
brave
firefox

# Communication Tools
slack

# Extra Tools
obsidian
]
