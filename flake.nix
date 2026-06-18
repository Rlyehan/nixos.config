{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Nix-native niri config + NixOS module (build-time validated KDL)
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "max";
      username = "max";

      mkHost =
        { systemModules, homeModules }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              system
              inputs
              username
              host
              ;
          };
          modules = [
            ./hosts/${host}/config.nix
          ]
          ++ systemModules
          ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit username inputs host; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = {
                imports = [
                  ./hosts/${host}/home.nix
                ]
                ++ homeModules;
              };
            }
          ];
        };

      configs = {
        "max-hyprland" = mkHost {
          systemModules = [ ./hosts/${host}/hyprland-system.nix ];
          homeModules = [ ./hosts/${host}/hyprland-home.nix ];
        };
        "max-cosmic" = mkHost {
          systemModules = [
            ./hosts/${host}/cosmic-system.nix
          ];
          homeModules = [ ./hosts/${host}/cosmic-home.nix ];
        };
        "max-niri" = mkHost {
          systemModules = [ ./hosts/${host}/niri-system.nix ];
          homeModules = [ ./hosts/${host}/niri-home.nix ];
        };
      };
    in
    {
      nixosConfigurations = configs // {
        "max" = configs."max-hyprland";
      };
    };
}
