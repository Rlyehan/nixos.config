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
      fr = "nh os switch --hostname ${host} /home/${username}/nixos.config";
      fu = "nh os switch --hostname ${host} --update /home/${username}/nixos.config";
      # Switch to Hyprland (boot — takes effect on next reboot)
      fh = "nh os boot --hostname ${host}-hyprland /home/${username}/nixos.config";
      fhu = "nh os boot --hostname ${host}-hyprland --update /home/${username}/nixos.config";
      # Switch to COSMIC (boot — takes effect on next reboot)
      fc = "nh os boot --hostname ${host}-cosmic /home/${username}/nixos.config";
      fcu = "nh os boot --hostname ${host}-cosmic --update /home/${username}/nixos.config";
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
