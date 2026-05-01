# i3 workspace helper functions.
#
# These build keybindings and labels for workspaces 11–19, which use
# Pango markup with per-workspace icon colors (Solarized palette).
#
# This file is pure — it has no system dependencies and is exercised
# by tests/workspace-bindings-test.nix via nix-unit.
{ lib }:

let
  colors = import ./colors.nix;

  # Color for each workspace 11..19 (index 0..8 in this list).
  # Order is intentional: cyan, green, yellow, orange, red, magenta,
  # violet, base01, blue — visually distinct around the color wheel.
  extWorkspaceColors = [
    colors.cyan
    colors.green
    colors.yellow
    colors.orange
    colors.red
    colors.magenta
    colors.violet
    colors.base01
    colors.blue
  ];

  # Build the Pango-marked-up label i3 uses for an extended workspace.
  # i3 uses this both as the workspace name and as the workspace number
  # (it parses the leading "N:" off the front).
  #
  # Example: mkExtLabel 11 "#2aa198"
  #   => "\"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\""
  mkExtLabel =
    num: color:
    "\"${toString num}:<span> </span>${toString num} <span foreground='${color}'></span><span> </span>\"";

  # All extended workspaces as a list of attrsets {num, color, label}.
  # Workspaces are numbered 11..19.
  extWorkspaces = lib.imap0 (i: color: {
    num = 11 + i;
    inherit color;
    label = mkExtLabel (11 + i) color;
  }) extWorkspaceColors;

  # Build a keybinding map for the extended workspaces.
  #
  #   modPrefix : the "Mod4+Ctrl+", "Mod4+Shift+Ctrl+", etc. portion
  #               (everything between "Mod" and the digit)
  #   action    : the i3 command to bind, e.g. "workspace number"
  #               or "move container to workspace number"
  #
  # The "Alt+Ctrl" case (which both moves and switches) is handled by the
  # caller passing a custom action string that uses ${label} as a
  # placeholder — see mkCarryBindings below.
  mkExtBindings =
    modPrefix: action:
    builtins.listToAttrs (
      map (w: {
        name = "${modPrefix}${toString (w.num - 10)}";
        value = "${action} ${w.label}";
      }) extWorkspaces
    );

  # The "carry" pattern: move container to workspace AND switch to it.
  # Each binding is "move container to workspace number L; workspace number L"
  # where L is the workspace's labeled name (with Pango markup).
  mkCarryBindings =
    modPrefix:
    builtins.listToAttrs (
      map (w: {
        name = "${modPrefix}${toString (w.num - 10)}";
        value = "move container to workspace number ${w.label}; workspace number ${w.label}";
      }) extWorkspaces
    );

  # Workspace-output assignments for i3 extraConfig.
  # Internal monitor gets workspaces 1..4, external gets 5..10.
  # If `external` is null, only internal-monitor lines are emitted.
  mkWorkspaceOutputs =
    {
      internal,
      external ? null,
    }:
    let
      line = n: out: "workspace ${toString n} output ${out}";
      internalLines = lib.concatMapStringsSep "\n" (n: line n internal) [
        1
        2
        3
        4
      ];
      externalLines = lib.optionalString (external != null) (
        "\n"
        + lib.concatMapStringsSep "\n" (n: line n external) [
          5
          6
          7
          8
          9
          10
        ]
      );
    in
    internalLines + externalLines;
in
{
  inherit
    extWorkspaces
    mkExtLabel
    mkExtBindings
    mkCarryBindings
    mkWorkspaceOutputs
    ;
}
