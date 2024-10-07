#!/usr/bin/env bash

if [ -n "$(grep -i nixos < /etc/os-release)" ]; then
  echo "Verified this is NixOS."
  echo "-----"
else
  echo "This is not NixOS or the distribution information is not available."
  exit
fi

hostName="max"

echo "Generating The Hardware Configuration"
sudo nixos-generate-config --show-hardware-config > ./hosts/$hostName/hardware.nix

echo "-----"

echo "Setting Required Nix Settings Then Going To Install"
NIX_CONFIG="experimental-features = nix-command flakes"

echo "-----"

sudo nixos-rebuild switch --flake ~/nixos.config/#${hostName}

echo "-----"
echo "Installing flatpaks"
flatpak install flathub com.github.IsmaelMartinez.teams_for_linux -y
flatpak install flathub org.keepassxc.KeePassXC -y
flatpak install flathub org.libreoffice.LibreOffice -y
