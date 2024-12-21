{
  config,
  pkgs,
  host,
  username,
  options,
  ...
}:

{
# Styling Options
stylix = {
  enable = false;
  image = ./wallpapers/nix.png;
  polarity = "dark";
  opacity.terminal = 0.8;
};
}
