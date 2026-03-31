# i3 Window Manager configuration (vanilla i3, migrated from Regolith)
{ config, pkgs, lib, ... }:

let
  volume-control = import ./volume.nix { inherit pkgs; };

  rofi-power-menu = pkgs.writeShellScriptBin "rofi-power-menu" ''
    options="Lock\nLogout\nSuspend\nReboot\nPower Off"
    chosen=$(echo -e "$options" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Power" -theme power-menu -mesg "Session")

    case "$chosen" in
      Lock)      /bin/i3lock -c 000000 ;;
      Logout)    ${pkgs.i3}/bin/i3-msg exit ;;
      Suspend)   systemctl suspend ;;
      Reboot)    systemctl reboot ;;
      "Power Off") systemctl poweroff ;;
    esac
  '';
in
{
  home.packages = [ rofi-power-menu volume-control ];

  # Enable xsession for display manager integration
  xsession = {
    enable = true;
    # Number of seconds to wait after starting xsession before running extra commands
    initExtra = '''';
    # Script to run before window manager starts
    profileExtra = '''';
  };

  # Create a desktop entry for GDM
  xdg.dataFile."xsessions/i3-home-manager.desktop".text =
    let
      homeDir = config.home.homeDirectory;
    in
    ''
      [Desktop Entry]
      Name=i3 (Home Manager)
      Comment=Improved tiling window manager (Home Manager managed)
      Exec=${homeDir}/.xsession
      Type=Application
      Keywords= tiling;wm;windowmanager;window;manager;
    '';

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;

    config = rec {
      modifier = "Mod4";

      fonts = {
        names = [ "MesloLGS Nerd Font" ];
        size = 12.0;
      };

      # Solarized Dark colors
      colors = {
        focused = {
          border = "#002b36";
          background = "#586e75";
          text = "#fdf6e3";
          indicator = "#dc322f";
          childBorder = "#b58900";
        };
        focusedInactive = {
          border = "#002b36";
          background = "#073642";
          text = "#839496";
          indicator = "#073642";
          childBorder = "#002b36";
        };
        unfocused = {
          border = "#002b36";
          background = "#073642";
          text = "#839496";
          indicator = "#073642";
          childBorder = "#002b36";
        };
        urgent = {
          border = "#002b36";
          background = "#dc322f";
          text = "#fdf6e3";
          indicator = "#dc322f";
          childBorder = "#002b36";
        };
      };

      # Window settings
      window = {
        border = 1;
        hideEdgeBorders = "smart";
        titlebar = false;
        commands = [
          {
            command = "border pixel 1";
            criteria = { class = "^.*"; };
          }
          {
            command = "floating enable";
            criteria = { class = "floating_window"; };
          }

        ];
      };

      floating = {
        border = 1;
        modifier = modifier;
        criteria = [
          { class = "floating_window"; }

        ];
      };

      focus = {
        followMouse = true;
        newWindow = "smart";
      };

      gaps = {
        inner = 10;
        outer = 0;
        smartGaps = true;
      };

      # Disable default bar (using polybar instead)
      bars = [ ];

      # Startup applications
      startup = [
        {
          command = "systemctl --user import-environment XDG_CURRENT_DESKTOP DISPLAY I3SOCK";
          always = false;
          notification = false;
        }
        {
          command = "dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP DISPLAY I3SOCK";
          always = false;
          notification = false;
        }
        {
          command = "/usr/bin/nm-applet";
          always = false;
          notification = false;
        }
        {
          command = "unclutter -b";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          always = false;
          notification = false;
        }
        {
          command = "copyq";
          always = false;
          notification = false;
        }
        {
          command = "dunst";
          always = false;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = true;
        }
        {
          command = "feh --bg-fill ${../assets/akash-mehrotra-2.jpg}";
          always = true;
          notification = false;
        }
      ];

      # Keybindings
      keybindings =
        let
          mod = modifier;
        in
        {
          # Navigation
          "${mod}+a" = "focus parent";
          "${mod}+z" = "focus child";
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";
          "${mod}+j" = "focus left";
          "${mod}+k" = "focus down";
          "${mod}+l" = "focus up";
          "${mod}+semicolon" = "focus right";

          # Workspaces 1-10
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          # Workspaces 11-19 (with Ctrl)
          "${mod}+Ctrl+1" = "workspace number \"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"";
          "${mod}+Ctrl+2" = "workspace number \"12:<span> </span>12 <span foreground='#859900'></span><span> </span>\"";
          "${mod}+Ctrl+3" = "workspace number \"13:<span> </span>13 <span foreground='#b58900'></span><span> </span>\"";
          "${mod}+Ctrl+4" = "workspace number \"14:<span> </span>14 <span foreground='#cb4b16'></span><span> </span>\"";
          "${mod}+Ctrl+5" = "workspace number \"15:<span> </span>15 <span foreground='#dc322f'></span><span> </span>\"";
          "${mod}+Ctrl+6" = "workspace number \"16:<span> </span>16 <span foreground='#d33682'></span><span> </span>\"";
          "${mod}+Ctrl+7" = "workspace number \"17:<span> </span>17 <span foreground='#6c71c4'></span><span> </span>\"";
          "${mod}+Ctrl+8" = "workspace number \"18:<span> </span>18 <span foreground='#586e75'></span><span> </span>\"";
          "${mod}+Ctrl+9" = "workspace number \"19:<span> </span>19 <span foreground='#268bd2'></span><span> </span>\"";

          # Workspace navigation
          "${mod}+Tab" = "workspace next";
          "${mod}+Mod1+Right" = "workspace next";
          "${mod}+Ctrl+Tab" = "workspace next_on_output";
          "${mod}+Ctrl+l" = "workspace next_on_output";
          "${mod}+Shift+Tab" = "workspace prev";
          "${mod}+Mod1+Left" = "workspace prev";
          "${mod}+Ctrl+Shift+Tab" = "workspace prev_on_output";
          "${mod}+Ctrl+h" = "workspace prev_on_output";
          "${mod}+Ctrl+a" = "scratchpad show";
          "${mod}+period" = "exec --no-startup-id pkill -USR1 -F \"\${XDG_RUNTIME_DIR}/swap_focus.pid\"";

          # Window movement
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";
          "${mod}+Shift+j" = "move left";
          "${mod}+Shift+k" = "move down";
          "${mod}+Shift+l" = "move up";
          "${mod}+Shift+semicolon" = "move right";

          # Move workspace to output
          "${mod}+Ctrl+Shift+Left" = "move workspace to output left";
          "${mod}+Ctrl+Shift+Right" = "move workspace to output right";
          "${mod}+Ctrl+Shift+Up" = "move workspace to output up";
          "${mod}+Ctrl+Shift+Down" = "move workspace to output down";
          "${mod}+Ctrl+Shift+h" = "move workspace to output left";
          "${mod}+Ctrl+Shift+j" = "move workspace to output down";
          "${mod}+Ctrl+Shift+k" = "move workspace to output up";
          "${mod}+Ctrl+Shift+l" = "move workspace to output right";

          # Window operations
          "${mod}+v" = "split vertical";
          "${mod}+g" = "split horizontal";
          "${mod}+BackSpace" = "split toggle";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+Shift+f" = "floating toggle";
          "${mod}+Ctrl+m" = "move to scratchpad";
          "${mod}+Shift+t" = "focus mode_toggle";
          "${mod}+t" = "layout toggle tabbed splith splitv";

          # Move containers to workspaces
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

          "${mod}+Shift+Ctrl+1" = "move container to workspace number \"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+2" = "move container to workspace number \"12:<span> </span>12 <span foreground='#859900'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+3" = "move container to workspace number \"13:<span> </span>13 <span foreground='#b58900'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+4" = "move container to workspace number \"14:<span> </span>14 <span foreground='#cb4b16'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+5" = "move container to workspace number \"15:<span> </span>15 <span foreground='#dc322f'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+6" = "move container to workspace number \"16:<span> </span>16 <span foreground='#d33682'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+7" = "move container to workspace number \"17:<span> </span>17 <span foreground='#6c71c4'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+8" = "move container to workspace number \"18:<span> </span>18 <span foreground='#586e75'></span><span> </span>\"";
          "${mod}+Shift+Ctrl+9" = "move container to workspace number \"19:<span> </span>19 <span foreground='#268bd2'></span><span> </span>\"";

          # Carry containers to workspaces (move + switch)
          "${mod}+Alt+1" = "move container to workspace number 1; workspace number 1";
          "${mod}+Alt+2" = "move container to workspace number 2; workspace number 2";
          "${mod}+Alt+3" = "move container to workspace number 3; workspace number 3";
          "${mod}+Alt+4" = "move container to workspace number 4; workspace number 4";
          "${mod}+Alt+5" = "move container to workspace number 5; workspace number 5";
          "${mod}+Alt+6" = "move container to workspace number 6; workspace number 6";
          "${mod}+Alt+7" = "move container to workspace number 7; workspace number 7";
          "${mod}+Alt+8" = "move container to workspace number 8; workspace number 8";
          "${mod}+Alt+9" = "move container to workspace number 9; workspace number 9";
          "${mod}+Alt+0" = "move container to workspace number 10; workspace number 10";

          "${mod}+Alt+Ctrl+1" = "move container to workspace number \"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"; workspace number \"11:<span> </span>11 <span foreground='#2aa198'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+2" = "move container to workspace number \"12:<span> </span>12 <span foreground='#859900'></span><span> </span>\"; workspace number \"12:<span> </span>12 <span foreground='#859900'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+3" = "move container to workspace number \"13:<span> </span>13 <span foreground='#b58900'></span><span> </span>\"; workspace number \"13:<span> </span>13 <span foreground='#b58900'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+4" = "move container to workspace number \"14:<span> </span>14 <span foreground='#cb4b16'></span><span> </span>\"; workspace number \"14:<span> </span>14 <span foreground='#cb4b16'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+5" = "move container to workspace number \"15:<span> </span>15 <span foreground='#dc322f'></span><span> </span>\"; workspace number \"15:<span> </span>15 <span foreground='#dc322f'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+6" = "move container to workspace number \"16:<span> </span>16 <span foreground='#d33682'></span><span> </span>\"; workspace number \"16:<span> </span>16 <span foreground='#d33682'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+7" = "move container to workspace number \"17:<span> </span>17 <span foreground='#6c71c4'></span><span> </span>\"; workspace number \"17:<span> </span>17 <span foreground='#6c71c4'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+8" = "move container to workspace number \"18:<span> </span>18 <span foreground='#586e75'></span><span> </span>\"; workspace number \"18:<span> </span>18 <span foreground='#586e75'></span><span> </span>\"";
          "${mod}+Alt+Ctrl+9" = "move container to workspace number \"19:<span> </span>19 <span foreground='#268bd2'></span><span> </span>\"; workspace number \"19:<span> </span>19 <span foreground='#268bd2'></span><span> </span>\"";

          # Resize mode
          "${mod}+r" = "mode resize";

          # Gaps
          "${mod}+minus" = "gaps inner current minus 6";
          "${mod}+plus" = "gaps inner current plus 6";
          "${mod}+Shift+minus" = "gaps inner current minus 12";
          "${mod}+Shift+plus" = "gaps inner current plus 12";

          # Launchers
          "${mod}+Return" = "exec --no-startup-id systemd-run --user --scope alacritty";
          "${mod}+Shift+Return" = "exec --no-startup-id systemd-run --user --scope gtk-launch $(xdg-settings get default-web-browser)";

          # Rofi launchers
          "${mod}+space" = "exec --no-startup-id rofi -show drun";
          "${mod}+Shift+space" = "exec --no-startup-id rofi -show run";
          "${mod}+Shift+question" = "exec --no-startup-id rofi -show keys";
          "${mod}+Ctrl+space" = "exec --no-startup-id rofi -show window";
          "${mod}+Mod1+space" = "exec --no-startup-id rofi -show filebrowser";

          # Session management
          "${mod}+Shift+q" = "kill";
          "${mod}+Mod1+q" = "exec --no-startup-id kill -9 $(xdotool getwindowfocus getwindowpid)";

          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+e" = "exec --no-startup-id rofi-power-menu";
          "${mod}+Escape" = "exec --no-startup-id loginctl lock-session";
          "${mod}+Shift+s" = "exec systemctl suspend";

          "${mod}+Shift+n" = "exec --no-startup-id /usr/bin/nautilus --new-window";

          # Volume keys
          "XF86AudioRaiseVolume" = "exec --no-startup-id volume up";
          "XF86AudioLowerVolume" = "exec --no-startup-id volume down";
          "XF86AudioMute" = "exec --no-startup-id volume toggle-mute";

          # Brightness keys
          "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set +10%";
          "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 10%-";

          # Bar toggle
          "${mod}+i" = "bar mode toggle";

          # CopyQ
          "${mod}+c" = "exec copyq menu";

          # Custom splits
          "${mod}+Shift+v" = "split vertical";
          "${mod}+Shift+h" = "split horizontal";
        };

      # Resize mode
      modes = {
        resize = {
          "Left" = "resize shrink width 6 px or 6 ppt";
          "Down" = "resize grow height 6 px or 6 ppt";
          "Up" = "resize shrink height 6 px or 6 ppt";
          "Right" = "resize grow width 6 px or 6 ppt";
          "Shift+Left" = "resize shrink width 24 px or 24 ppt";
          "Shift+Down" = "resize grow height 24 px or 24 ppt";
          "Shift+Up" = "resize shrink height 24 px or 24 ppt";
          "Shift+Right" = "resize grow width 24 px or 24 ppt";
          "j" = "resize shrink width 6 px or 6 ppt";
          "l" = "resize grow height 6 px or 6 ppt";
          "k" = "resize shrink height 6 px or 6 ppt";
          "semicolon" = "resize grow width 6 px or 6 ppt";
          "Shift+j" = "resize shrink width 24 px or 24 ppt";
          "Shift+l" = "resize grow height 24 px or 24 ppt";
          "Shift+k" = "resize shrink height 24 px or 24 ppt";
          "Shift+semicolon" = "resize grow width 24 px or 24 ppt";
          "Return" = "mode default";
          "Escape" = "mode default";
          "${modifier}+r" = "mode default";
        };
      };
    };

    # Extra config for workspace output assignments and window rules
    extraConfig = ''
      # Popup during fullscreen
      popup_during_fullscreen smart

      # Machine-specific workspace outputs will be appended by machine configs

      # Window rules
      for_window [class="zoom" title="Zoom - Licensed Account"] move to workspace 4
      no_focus [class="zoom" title="Zoom - Licensed Account"]
      for_window [class="zoom"] move to workspace 3
    '';
  };
}
