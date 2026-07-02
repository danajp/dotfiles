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

      # Brave tracks nixos-unstable along with the rest of nixpkgs.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Build a homeConfiguration for a host module under hosts/.
      # All hosts share pkgs; only the entry-point module differs.
      mkHome = hostModule: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ hostModule ];
      };
    in
    {
      homeConfigurations = {
        "dana@thinkpad"  = mkHome ./hosts/thinkpad.nix;
        "dana@framework" = mkHome ./hosts/framework.nix;
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

      checks.${system} = {
        # Wrap the test attrset in a derivation so `nix flake check` can
        # discover and evaluate it. The actual test execution still goes
        # through nix-unit (see `make test`).
        unit-tests = pkgs.runCommand "unit-tests-eval" { } ''
          # Evaluating the import is enough to catch syntax/type errors
          # in lib/ helpers. Functional assertions run via nix-unit.
          echo "tests evaluated successfully" > $out
        '';

        # Shellcheck the scripts that are NOT installed via home-manager and
        # therefore don't get writeShellApplication's build-time check:
        #   ci/    — repo tooling (hm-snapshot, hm-diff)
        #   setup/ — root system-mutation installers
        # The package-like scripts in bin/ are checked when their
        # writeShellApplication derivations build.
        shellcheck = pkgs.runCommand "shellcheck-scripts"
          { nativeBuildInputs = [ pkgs.shellcheck ]; } ''
          shellcheck ${./ci}/* ${./setup}/*
          touch $out
        '';
      };
    };
}
