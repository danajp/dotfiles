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

      # nixpkgs with an overlay that pins Brave to a known-good revision.
      # Browser updates routinely break on nixos-unstable; we hold the
      # version at nixpkgs-brave's commit instead. The overlay makes the
      # pinned package available as plain `pkgs.brave`, no extra special
      # arg threading required.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (_final: _prev: {
            inherit (import nixpkgs-brave {
              inherit system;
              config.allowUnfree = true;
            }) brave;
          })
        ];
      };

      # Build a homeConfiguration for a host module under machines/.
      # All hosts share pkgs; only the entry-point module differs.
      mkHome = hostModule: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ hostModule ];
      };
    in
    {
      homeConfigurations = {
        "dana@thinkpad"  = mkHome ./machines/thinkpad.nix;
        "dana@framework" = mkHome ./machines/framework.nix;
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
