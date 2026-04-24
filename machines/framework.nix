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
        fingerprint = {
          "${internalMonitor}" = "00ffffffffffff0009e5c90b0000000030200104a5221678033d35ae5043b1250e505400000001010101010101010101010101010101347000a0a040a0603020f60c59d71000001a000000000000000000000000000000000000000000fe00424f452043510a202020202020000000fe004e4531363051444d2d4e5a360a010a70207902002200147f0d0c85ff099f002f001f003f069f003e0005002500097f0d0c7f0d0c3ca580810013721a000003c13ca500006a426a42a5002faa0c21011d770d6a08000a400688e1aa503d24b151d20e023554b05cb05ccc3412782600090200000000001000000000000000000000000000000000000000000000f790";
        };
        config = {
          "${internalMonitor}" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1200";
          };
        };
      };
      docked = {
        fingerprint = {
          "${internalMonitor}" = "00ffffffffffff0009e5c90b0000000030200104a5221678033d35ae5043b1250e505400000001010101010101010101010101010101347000a0a040a0603020f60c59d71000001a000000000000000000000000000000000000000000fe00424f452043510a202020202020000000fe004e4531363051444d2d4e5a360a010a70207902002200147f0d0c85ff099f002f001f003f069f003e0005002500097f0d0c7f0d0c3ca580810013721a000003c13ca500006a426a42a5002faa0c21011d770d6a08000a400688e1aa503d24b151d20e023554b05cb05ccc3412782600090200000000001000000000000000000000000000000000000000000000f790";
          "${externalMonitor}" = "00ffffffffffff000469a327ae3001000b1b0104a53c22783aa595aa544fa1260a5054b7ef00d1c0b300950081808140810081c0714f565e00a0a0a029503020350055502100001a000000ff0048334c4d54463037373939380a000000fd00184c18631e04110140f838f03c000000fc00415355532050423237380a2020015e020322714f0102031112130414051f900e0f1d1e2309170783010000656e0c0010008c0ad08a20e02d10103e9600555021000018011d007251d01e206e28550055502100001e011d00bc52d01e20b828554055502100001e8c0ad090204031200c40550055502100001800000000000000000000000000000000000000000096";
        };
        config = {
          "${internalMonitor}" = {
            enable = true;
            primary = true;
            position = "2560x0";
            mode = "1920x1200";
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

  # Atlassian Jira MCP server (OAuth-based, via mcp.atlassian.com)
  programs.opencode.settings.mcp.atlassian = {
    type = "remote";
    url = "https://mcp.atlassian.com/v1/mcp";
    oauth = {};
  };
}
