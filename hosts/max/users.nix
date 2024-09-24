{
  pkgs,
  username,
  ...
}:


{
  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
