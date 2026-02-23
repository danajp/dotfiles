{
  description = "Home Manager configuration of dana";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."dana@thinkpad" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./machines/thinkpad.nix ];
      };

      homeConfigurations."dana@framework" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./machines/framework.nix ];
      };
    };
}
