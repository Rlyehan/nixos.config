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
  image = ./wallpapers/cool.jpg;
  polarity = "dark";
  opacity.terminal = 0.8;
};
}
