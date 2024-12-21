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
  enable = true;
  image = ./wallpapers/nix.png;
  polarity = "dark";
  opacity.terminal = 0.8;
};
}
