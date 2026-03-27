# Machine-specific configuration for thinkpad
{ config, pkgs, ... }:

let
  # Monitor configuration for thinkpad
  internalMonitor = "eDP-1";
  externalMonitor = "DP-2-1";
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
        fingerprint = {
          "${internalMonitor}" = "00ffffffffffff0034a9a29600000000ff190104a51f1178026b65a4514b9b270f5054000000010101010101010101010101010101019a6400f0a0a05d505820c50435ad1000001e976400f0a0a0dc515820c50435ad1000001e000000fd002e3e595e1a010a202020202020000000fe005656583134543035384a30320a0008";
        };
        config = {
          "${internalMonitor}" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
          };
        };
        hooks.postswitch = "i3-msg restart";
      };
      docked = {
        fingerprint = {
          "${internalMonitor}" = "00ffffffffffff0034a9a29600000000ff190104a51f1178026b65a4514b9b270f5054000000010101010101010101010101010101019a6400f0a0a05d505820c50435ad1000001e976400f0a0a0dc515820c50435ad1000001e000000fd002e3e595e1a010a202020202020000000fe005656583134543035384a30320a0008";
          "${externalMonitor}"="00ffffffffffff000469a327ae3001000b1b0104a53c22783aa595aa544fa1260a5054b7ef00d1c0b300950081808140810081c0714f565e00a0a0a029503020350055502100001a000000ff0048334c4d54463037373939380a000000fd00184c18631e04110140f838f03c000000fc00415355532050423237380a2020015e020322714f0102031112130414051f900e0f1d1e2309170783010000656e0c0010008c0ad08a20e02d10103e9600555021000018011d007251d01e206e28550055502100001e011d00bc52d01e20b828554055502100001e8c0ad090204031200c40550055502100001800000000000000000000000000000000000000000096";
        };
        config = {
          "${internalMonitor}" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
          };
          "${externalMonitor}" = {
            enable = true;
            primary = false;
            position = "1920x0";
            mode = "2560x1440";
          };
        };
        hooks.postswitch = "i3-msg restart";
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
  '';

  # Machine-specific oh-my-opencode config
  xdg.configFile."opencode/oh-my-opencode.json".source = ../dot/config/opencode/oh-my-opencode-thinkpad.json;
}
