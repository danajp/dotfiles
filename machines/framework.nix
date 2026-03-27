# Machine-specific configuration for framework
{ config, pkgs, ... }:

let
  # Monitor configuration for framework
  internalMonitor = "eDP-1";
  externalMonitor = "DisplayPort-1-0";
in
{
  imports = [ ./common.nix ];

  # Autorandr profiles for display configuration
  # To capture fingerprints for auto-detection, run:
  #   autorandr --save undocked  (when only internal monitor is connected)
  #   autorandr --save docked    (when both monitors are connected)
  programs.autorandr = {
    enable = true;
    profiles = {
      undocked = {
        config = {
          "${internalMonitor}" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2256x1504";
          };
        };
      };
      docked = {
        config = {
          "${internalMonitor}" = {
            enable = true;
            primary = true;
            position = "2560x0";
            mode = "2256x1504";
          };
          "${externalMonitor}" = {
            enable = true;
            primary = false;
            position = "0x0";
            mode = "2560x1440";
          };
        };
      };
    };
  };

  # Machine-specific i3 workspace output assignments
  xsession.windowManager.i3.extraConfig = ''
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

    # for fingerprint reader
    exec --no-startup-id /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
  '';

  # Machine-specific oh-my-opencode config
  xdg.configFile."opencode/oh-my-opencode.json".source = ../dot/config/opencode/oh-my-opencode-framework.json;
}
