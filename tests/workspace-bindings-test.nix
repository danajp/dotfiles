# Unit tests for lib/i3-workspaces.nix.
#
# Run with:
#   nix run nixpkgs#nix-unit -- --flake .#tests
# Or via:
#   make test
#
# Each top-level "test*" attribute is one assertion. The test framework
# evaluates `expr` and `expected` and reports any mismatch.
#
# This file is pure — no IO, no nixpkgs needed beyond `lib`.
{ lib }:

let
  ws = import ../lib/i3-workspaces.nix { inherit lib; };
  colors = import ../lib/colors.nix;
in
{
  # ── extWorkspaces structure ──────────────────────────────────────

  testExtWorkspacesHasNineEntries = {
    expr = builtins.length ws.extWorkspaces;
    expected = 9;
  };

  testExtWorkspacesNumberedFrom11 = {
    expr = map (w: w.num) ws.extWorkspaces;
    expected = [
      11
      12
      13
      14
      15
      16
      17
      18
      19
    ];
  };

  testExtWorkspace11IsCyan = {
    expr = (builtins.head ws.extWorkspaces).color;
    expected = colors.cyan;
  };

  # ── mkExtLabel format ────────────────────────────────────────────
  # The expected string here is exactly what currently appears in the
  # production i3.nix for workspace 11 (line 218). If this test starts
  # failing during a refactor, the generated i3 config will not be
  # byte-identical to the baseline — investigate before proceeding.

  testExtLabel11 = {
    expr = ws.mkExtLabel 11 colors.cyan;
    expected = "\"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"";
  };

  testExtLabel19 = {
    expr = ws.mkExtLabel 19 colors.blue;
    expected = "\"19:<span> </span>19 <span foreground='#268bd2'></span><span> </span>\"";
  };

  # ── mkExtBindings ────────────────────────────────────────────────

  testExtBindingsKeyCount = {
    expr = builtins.length (builtins.attrNames (ws.mkExtBindings "Mod4+Ctrl+" "workspace number"));
    expected = 9;
  };

  # Spot-check: Mod4+Ctrl+1 should map to workspace 11
  testExtBindingMod4Ctrl1 = {
    expr = (ws.mkExtBindings "Mod4+Ctrl+" "workspace number")."Mod4+Ctrl+1";
    expected = "workspace number \"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"";
  };

  # Spot-check: Mod4+Ctrl+9 should map to workspace 19
  testExtBindingMod4Ctrl9 = {
    expr = (ws.mkExtBindings "Mod4+Ctrl+" "workspace number")."Mod4+Ctrl+9";
    expected = "workspace number \"19:<span> </span>19 <span foreground='#268bd2'></span><span> </span>\"";
  };

  # Move-container variant
  testMoveContainerBinding = {
    expr =
      (ws.mkExtBindings "Mod4+Shift+Ctrl+" "move container to workspace number")."Mod4+Shift+Ctrl+5";
    expected = "move container to workspace number \"15:<span> </span>15 <span foreground='#dc322f'></span><span> </span>\"";
  };

  # ── mkCarryBindings (move + switch) ──────────────────────────────

  testCarryBinding = {
    expr = (ws.mkCarryBindings "Mod4+Alt+Ctrl+")."Mod4+Alt+Ctrl+1";
    expected = "move container to workspace number \"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"; workspace number \"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"";
  };

  # ── mkWorkspaceOutputs ───────────────────────────────────────────

  testWorkspaceOutputsBothMonitors = {
    expr = ws.mkWorkspaceOutputs {
      internal = "eDP-1";
      external = "DP-2-1";
    };
    expected = ''
      workspace 1 output eDP-1
      workspace 2 output eDP-1
      workspace 3 output eDP-1
      workspace 4 output eDP-1
      workspace 5 output DP-2-1
      workspace 6 output DP-2-1
      workspace 7 output DP-2-1
      workspace 8 output DP-2-1
      workspace 9 output DP-2-1
      workspace 10 output DP-2-1'';
  };

  testWorkspaceOutputsInternalOnly = {
    expr = ws.mkWorkspaceOutputs { internal = "eDP-1"; };
    expected = ''
      workspace 1 output eDP-1
      workspace 2 output eDP-1
      workspace 3 output eDP-1
      workspace 4 output eDP-1'';
  };
}
