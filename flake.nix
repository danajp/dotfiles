{
  description = "Home Manager configuration of dana";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned nixpkgs for brave-browser 1.87.191
    nixpkgs-brave.url = "github:nixos/nixpkgs/0c39f3b5a9a234421d4ad43ab9c7cf64840172d0";
  };

  outputs =
    { nixpkgs, home-manager, nixpkgs-brave, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        pkgs-brave = import nixpkgs-brave {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
      homeConfigurations."dana@thinkpad" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [ ./machines/thinkpad.nix ];
      };

      homeConfigurations."dana@framework" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [ ./machines/framework.nix ];
      };
    };
}
