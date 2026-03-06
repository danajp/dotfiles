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

  # Machine-specific i3 workspace output assignments and display config
  xsession.windowManager.i3.extraConfig = ''
    # TODO: Set display resolutions and positions for Framework
    # exec --no-startup-id xrandr --output ${internalMonitor} --primary --mode 2256x1504 --pos 0x0
    # exec --no-startup-id xrandr --output ${externalMonitor} --mode 2560x1440 --pos 2256x0

    # Workspace output assignments
    workspace 1 output ${internalMonitor}
    workspace 2 output ${internalMonitor}
    workspace 3 output ${internalMonitor}
    workspace 4 output ${internalMonitor}
    workspace 5 output ${externalMonitor}
    workspace 6 output ${externalMonitor}
    workspace 7 output ${externalMonitor}
    workspace 8 output ${externalMonitor}
    workspace 9 output ${externalMonitor}
    workspace 10 output ${externalMonitor}
  '';

  # Machine-specific oh-my-opencode config
  xdg.configFile."opencode/oh-my-opencode.json".source = ../dot/config/opencode/oh-my-opencode-framework.json;
}
