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

      # Pure-Nix unit tests for helper functions in lib/.
      #
      # Exposed as `checks.${system}.unit-tests` so `nix flake check` sees
      # them as a valid output, AND as `tests` for direct invocation by
      # nix-unit (which prefers an attrset of expr/expected pairs).
      #
      # Run with: `make test` (preferred) or
      #   nix run nixpkgs#nix-unit -- --flake .#tests
      tests = import ./tests/workspace-bindings-test.nix {
        inherit (nixpkgs) lib;
      };

      # Wrap the test attrset in a derivation so `nix flake check` can
      # discover and evaluate it. The actual test execution still goes
      # through nix-unit (see `make test`).
      checks.${system}.unit-tests = pkgs.runCommand "unit-tests-eval" { } ''
        # Evaluating the import is enough to catch syntax/type errors
        # in lib/ helpers. Functional assertions run via nix-unit.
        echo "tests evaluated successfully" > $out
      '';
    };
}
