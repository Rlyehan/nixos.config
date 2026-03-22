{
  pkgs,
  host,
  username,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    profileExtra = ''
      #if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      #  exec Hyprland
      #fi
    '';
    shellAliases = {
      # NixOS rebuild (current config, defaults to hyprland)
      fr = "sudo nixos-rebuild switch --flake /home/${username}/nixos.config#$(readlink /run/current-system | grep -q cosmic && echo '${host}-cosmic' || echo '${host}-hyprland')";
      fu = "sudo nix flake update --flake /home/${username}/nixos.config && sudo nixos-rebuild switch --flake /home/${username}/nixos.config#$(readlink /run/current-system | grep -q cosmic && echo '${host}-cosmic' || echo '${host}-hyprland')";
      # Switch to Hyprland (boot — takes effect on next reboot)
      fh = "sudo nixos-rebuild boot --flake /home/${username}/nixos.config#${host}-hyprland";
      fhu = "sudo nix flake update --flake /home/${username}/nixos.config && sudo nixos-rebuild boot --flake /home/${username}/nixos.config#${host}-hyprland";
      # Switch to COSMIC (boot — takes effect on next reboot)
      fc = "sudo nixos-rebuild boot --flake /home/${username}/nixos.config#${host}-cosmic";
      fcu = "sudo nix flake update --flake /home/${username}/nixos.config && sudo nixos-rebuild boot --flake /home/${username}/nixos.config#${host}-cosmic";
      # Garbage collection
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      cat = "bat";
      ls = "eza --icons";
      la = "eza -l -o -h --icons --group-directories-first";
      lg = "lazygit";
      teams = "flatpak run com.github.IsmaelMartinez.teams_for_linux";
      keepass = "flatpak run org.keepassxc.KeePassXC";
    };
  };
}
