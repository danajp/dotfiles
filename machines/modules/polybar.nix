# Polybar status bar.
#
# NOTE: Systemd service manually disabled. Polybar is started by i3
# instead - see the `startup` block in i3.nix. Run once on a fresh
# install: systemctl --user disable polybar
{ pkgs, ... }:

{
  services.polybar = {
    # NOTE: Systemd service manually disabled. Polybar is started by i3 instead.
    # Run: systemctl --user disable polybar
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };

    # Solarized Dark palette
    # base03  #002b36  base02  #073642
    # base01  #586e75  base00  #657b83
    # base0   #839496  base1   #93a1a1
    # yellow  #b58900  orange  #cb4b16
    # red     #dc322f  magenta #d33682
    # violet  #6c71c4  blue    #268bd2
    # cyan    #2aa198  green   #859900

    config = {
      "colors" = {
        background = "#002b36";
        background-alt = "#073642";
        foreground = "#839496";
        foreground-alt = "#586e75";
        primary = "#268bd2";
        alert = "#dc322f";
        warning = "#b58900";
        green = "#859900";
        cyan = "#2aa198";
        magenta = "#d33682";
        violet = "#6c71c4";
      };

      "bar/top" = {
        monitor = "\${env:MONITOR:}";
        width = "100%";
        height = "24px";
        radius = 0;
        background = "\${colors.background}";
        foreground = "\${colors.foreground}";
        separator = " ";

        # Primary font + Nerd Font for icons
        font-0 = "Inconsolata:size=14;3";
        font-1 = "MesloLGS Nerd Font:size=13;3";

        modules-left = "i3 xwindow";
        modules-right = "net-traffic bluetooth vpn cpu memory battery pulseaudio time-utc time-local tray";

        line-size = 2;
        padding = 1;
        module-margin = 1;
      };

      # ── System tray ───────────────────────────────────────────
      "module/tray" = {
        type = "internal/tray";
        tray-spacing = "8px";
        tray-padding = "4px";
      };

      # ── Left side ──────────────────────────────────────────────

      # i3 workspaces
      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        strip-wsnumbers = false;
        index-sort = true;
        enable-click = true;
        enable-scroll = false;
        wrapping-scroll = false;

        label-focused = "%name%";
        label-focused-foreground = "\${colors.background}";
        label-focused-background = "\${colors.primary}";
        label-focused-padding = 1;

        label-unfocused = "%name%";
        label-unfocused-foreground = "\${colors.foreground-alt}";
        label-unfocused-padding = 1;

        label-visible = "%name%";
        label-visible-foreground = "\${colors.foreground}";
        label-visible-underline = "\${colors.primary}";
        label-visible-padding = 1;

        label-urgent = "%name%";
        label-urgent-foreground = "\${colors.background}";
        label-urgent-background = "\${colors.alert}";
        label-urgent-padding = 1;
      };

      # Focused window name (was: 10_focused-window-name)
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
        label-foreground = "\${colors.foreground}";
      };

      # ── Right side (ordered to match i3xrocks numbering) ──────

      # Network traffic (was: 30_net-traffic)
      "module/net-traffic" = {
        type = "internal/network";
        interface-type = "wired";
        interval = 3;
        format-connected = "<label-connected>";
        label-connected = "%{T2}%{T-} %downspeed% %{T2}%{T-} %upspeed% %{T2}%{T-}";
        label-connected-foreground = "\${colors.cyan}";
        format-disconnected = "<label-disconnected>";
        label-disconnected = " %{T2}%{T-} --";
        label-disconnected-foreground = "\${colors.foreground-alt}";
      };

      # Bluetooth (was: 30_bluetooth) - custom script
      "module/bluetooth" = {
        type = "custom/script";
        exec = ''/usr/bin/bluetoothctl show 2>/dev/null | /usr/bin/grep -q "Powered: yes" && echo "%{T2}%{T-}" || echo ""'';
        interval = 20;
        label-foreground = "\${colors.primary}";
        click-left = "/usr/bin/bluetoothctl power on";
        click-right = "/usr/bin/bluetoothctl power off";
      };

      # VPN (was: 40_nm-vpn) - custom script
      "module/vpn" = {
        type = "custom/script";
        exec = ''/usr/bin/nmcli -t connection show --active 2>/dev/null | /usr/bin/grep -q vpn && echo "%{T2}%{T-} VPN" || echo ""'';
        interval = 30;
        label-foreground = "\${colors.green}";
      };

      # CPU usage (was: 40_cpu-usage)
      "module/cpu" = {
        type = "internal/cpu";
        interval = 5;
        format = "<label>";
        label = "%{T2}%{T-} %percentage%%";
        label-foreground = "\${colors.foreground}";
        warn-percentage = 80;
        format-warn = "<label-warn>";
        label-warn = "%{T2}%{T-} %percentage%%";
        label-warn-foreground = "\${colors.alert}";
      };

      # Memory (was: 50_memory)
      "module/memory" = {
        type = "internal/memory";
        interval = 10;
        format = "<label>";
        label = "%{T2}%{T-} %percentage_used%%";
        label-foreground = "\${colors.foreground}";
        warn-percentage = 90;
        format-warn = "<label-warn>";
        label-warn = "%{T2}%{T-} %percentage_used%%";
        label-warn-foreground = "\${colors.alert}";
      };

      # Battery (was: 80_battery)
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        full-at = 98;
        poll-interval = 10;

        format-charging = "<label-charging>";
        label-charging = "%{T2}%{T-} %percentage%%";
        label-charging-foreground = "\${colors.green}";

        format-discharging = "<label-discharging>";
        label-discharging = "%{T2}%{T-} %percentage%%";
        label-discharging-foreground = "\${colors.warning}";

        format-full = "<label-full>";
        label-full = "%{T2}%{T-} %percentage%%";
        label-full-foreground = "\${colors.green}";
      };

      # Volume (was: 80_volume)
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        interval = 5;
        format-volume = "<label-volume>";
        label-volume = "%{T2}%{T-} %percentage%%";
        label-volume-foreground = "\${colors.foreground}";
        format-muted = "<label-muted>";
        label-muted = "%{T2}%{T-} muted";
        label-muted-foreground = "\${colors.foreground-alt}";
        click-right = "pavucontrol";
      };

      # UTC time (was: 85_utc)
      "module/time-utc" = {
        type = "custom/script";
        exec = "TZ=UTC /usr/bin/date +'%Y-%m-%d %H:%M:%S %Z'";
        interval = 1;
        label = "%{T2}%{T-} %output%";
        label-foreground = "\${colors.violet}";
      };

      # Local time (was: 90_time)
      "module/time-local" = {
        type = "internal/date";
        interval = 1;
        date = "%Y-%m-%d";
        time = "%H:%M:%S %Z";
        label = "%{T2}%{T-} %date% %time%";
        label-foreground = "\${colors.primary}";
      };


    };

    script = ''
      PATH="${pkgs.procps}/bin:${pkgs.coreutils}/bin:${pkgs.iproute2}/bin:${pkgs.i3}/bin:${pkgs.gnugrep}/bin:$PATH"
      export PATH

      killall -q polybar
      for m in $(polybar --list-monitors | cut -d: -f1); do
        MONITOR="$m" polybar top &
      done
    '';
  };

  systemd.user.services.polybar = {
    # Make sure polybar restarts quickly
    Service = {
      KillSignal = "SIGTERM";
      TimeoutStopSec = 1;
    };
  };
}
