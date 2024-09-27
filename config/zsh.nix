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
    fr = "nh os switch --hostname ${host} /home/${username}/zaneyos";
    fu = "nh os switch --hostname ${host} --update /home/${username}/zaneyos";
    ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    cat = "bat";
    ls = "eza --icons";
    ll = "eza -lh --icons --grid --group-directories-first";
    la = "eza -lah --icons --grid --group-directories-first";
    lg = "lazygit";
    ld = "lazydocker";
  };
};
}
