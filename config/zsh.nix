{ pkgs, host, username, ... }:

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
    fr = "nh os switch --hostname ${host} /home/${username}/nixos.config";
    fu = "nh os switch --hostname ${host} --update /home/${username}/nixos.config";
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
