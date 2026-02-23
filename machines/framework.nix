# Machine-specific configuration for framework
{ config, pkgs, ... }:

let
  # Monitor configuration for framework
  # TODO: Update these values for your Framework laptop
  internalMonitor = "eDP-1";  # Placeholder - update with actual monitor name
  externalMonitor = "DP-1";   # Placeholder - update with actual monitor name
in
{
  imports = [ ./common.nix ];

  # Machine-specific i3 config with monitor assignments
  xdg.configFile."regolith3/i3/config.d/custom".text = ''
    set $internal_monitor ${internalMonitor}
    set $external_monitor ${externalMonitor}

    workspace $ws1 output $internal_monitor
    workspace $ws2 output $internal_monitor
    workspace $ws3 output $internal_monitor
    workspace $ws4 output $internal_monitor

    workspace $ws5 output $external_monitor
    workspace $ws6 output $external_monitor
    workspace $ws7 output $external_monitor
    workspace $ws8 output $external_monitor
    workspace $ws9 output $external_monitor
    workspace $ws10 output $external_monitor

    bindsym $mod+c exec copyq menu
    bindsym $mod+shift+v split v
    bindsym $mod+shift+h split h

    # main window
    for_window [class="zoom" title="Zoom - Licensed Account"] move to workspace $ws4
    no_focus [class="zoom" title="Zoom - Licensed Account"]
    # popup notifications (note lowercase z)
    #for_window [class="zoom" title="zoom"] floating enable
    # meeting windows have title "Zoom" (notexpr capital Z) or "Zoom Meeting"
    for_window [class="zoom"] move to workspace $ws3

    exec --no-startup-id /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
  '';

  # Machine-specific oh-my-opencode config
  xdg.configFile."opencode/oh-my-opencode.json".source = ../dot/config/opencode/oh-my-opencode-framework.json;
}
