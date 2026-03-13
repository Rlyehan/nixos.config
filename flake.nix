{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-cosmic, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "max";
      username = "max";
      pkgs = nixpkgs.legacyPackages.${system};

      mkHost = { systemModules, homeModules }: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system inputs username host; };
        modules = [
          ./hosts/${host}/config.nix
        ] ++ systemModules ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit username inputs host; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = { imports = [
              ./hosts/${host}/home.nix
            ] ++ homeModules; };
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
            nixos-cosmic.nixosModules.default
            ./hosts/${host}/cosmic-system.nix
          ];
          homeModules = [ ./hosts/${host}/cosmic-home.nix ];
        };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          llvmPackages_19.libcxx
          llvmPackages_19.clang
          cmake
          ninja
          python3
        ];

        shellHook = ''
          export CXXFLAGS="-isystem ${pkgs.llvmPackages_19.libcxx}/include/c++/v1"
          export CPLUS_INCLUDE_PATH="${pkgs.llvmPackages_19.libcxx}/include/c++/v1"
        '';
      };

      nixosConfigurations = configs // { "max" = configs."max-hyprland"; };
    };
}
