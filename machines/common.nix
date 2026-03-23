# Common Home Manager configuration shared across all machines
{ config, pkgs, pkgs-brave, ... }:

{
  imports = [ ./i3.nix ];
  # enable gpu on non nixos linux
  # see https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
  targets.genericLinux.gpu.enable = true;
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dana";
  home.homeDirectory = "/home/dana";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.asdf-vm
    pkgs.devenv
    pkgs.pamixer
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dana/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.brave = {
    enable = true;
    package = pkgs-brave.brave;
    extensions = [
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
    ];
  };

  programs.bun.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Dana Pieluszczak";
        email = "danajp@users.noreply.github.com";
      };
      github.user = "danajp";
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      color = {
        log = "auto";
        diff = "auto";
        status = "auto";
      };
      push.default = "upstream";
      commit.gpgsign = true;
      init.defaultBranch = "main";

      alias = {
        lg ="log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
        lgnc ="log --graph --abbrev-commit --decorate --date=relative --format=format:'%h - (%ar) %s - %an%d'";
        lga = "!git lg --all";
        up = "!git remote update --prune; git merge --ff-only @{upstream}";
        mup = "merge --ff-only @{upstream}";
      };
    };
    ignores = [
      ".aider.chat.history.md"
      ".aider.tags.cache.*/"
    ];
    includes = [
      { path = "~/.gitconfig-signing"; }
    ];
  };

  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        "@opencode-ai/plugin"
        "oh-my-openagent"
        # https://github.com/shahidshabbir-se/opencode-anthropic-oauth/tree/master
        "opencode-anthropic-oauth"
      ];
    };
  };

  programs.claude-code = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    mouse = true;
    historyLimit = 20000;
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = power-theme;
        extraConfig = ''
          run-shell "powerline-daemon -q"
          source /usr/share/powerline/bindings/tmux/powerline.conf
        '';
      }
    ];
  };

  home.file.".asdfrc".source = ../dot/asdfrc;
  home.file.".gemrc".source = ../dot/gemrc;

  # XDG config files
  xdg.enable = true;
  xdg.configFile = {
    # Rofi solarized-dark theme
    "rofi/solarized-dark.rasi".source = ../dot/config/rofi/solarized-dark.rasi;
    "rofi/power-menu.rasi".source = ../dot/config/rofi/power-menu.rasi;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = ''
        $kubernetes$directory$git_branch$git_status$aws$direnv$nix_shell$cmd_duration$fill$time''${custom.local_time}$line_break$character
      '';
      kubernetes.disabled = false;
      ruby.disabled = true;
      nodejs.disabled = true;
      gcloud.disabled = true;
      golang.disabled = true;
      python.disabled = true;
      package.disabled = true;
      terraform.disabled = true;
      vagrant.disabled = true;
      aws.region_aliases = {
        us-east-1 = "use1";
        us-west-2 = "usw2";
        eu-central-1 = "euc1";
        eu-west-1 = "euw1";
        ap-southeast-2 = "apse2";
        ap-southeast-4 = "apse4";
      };
      time = {
        disabled = false;
        utc_time_offset = "0";
        time_format = "%T UTC";
        format = "[$time]($style) ";
      };
      custom.local_time = {
        description = "show local time";
        when = true;
        command = "date +'%T %Z'";
        format = "[$output]($style)";
      };
      fill.symbol = " ";
      direnv.disabled = false;
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      #theme = "dark:iTerm2 Solarized Dark,light:iTerm2 Solarized Light";
      theme = "iTerm2 Solarized Dark";
      font-family = "Inconsolata";
      font-size = 12.0;
      window-decoration = "none";
      mouse-scroll-multiplier = 0.5;
      app-notifications = "no-clipboard-copy";
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "Inconsolata 14";
    theme = "solarized-dark";
    extraConfig = {
      modi = "drun,run,window,ssh";
      show-icons = true;
      icon-theme = "Adwaita";
      drun-display-format = "{name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
      display-ssh = "SSH";
    };
  };

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

    script = let
      polybarPkg = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
    in ''
      PATH="${pkgs.procps}/bin:${pkgs.coreutils}/bin:${pkgs.iproute2}/bin:${pkgs.i3}/bin:${pkgs.gnugrep}/bin:$PATH"
      export PATH

      launch_bars() {
        timeout=10
        while [ -z "$I3SOCK" ] && [ $timeout -gt 0 ]; do
          export I3SOCK=$(${pkgs.i3}/bin/i3 --get-socketpath 2>/dev/null || echo "")
          ${pkgs.coreutils}/bin/sleep 0.5
          timeout=$((timeout - 1))
        done
        [ -n "$I3SOCK" ] && export I3SOCK

        ${pkgs.procps}/bin/killall -q polybar || true
        while ${pkgs.procps}/bin/pgrep -u $UID -x polybar >/dev/null; do ${pkgs.coreutils}/bin/sleep 0.5; done
        for m in $(${polybarPkg}/bin/polybar --list-monitors 2>/dev/null | ${pkgs.coreutils}/bin/cut -d: -f1); do
          MONITOR=$m ${polybarPkg}/bin/polybar top &
        done
      }

      ${pkgs.coreutils}/bin/sleep 2
      launch_bars

      ${pkgs.i3}/bin/i3-msg -t subscribe -m '["output"]' 2>/dev/null | while read -r line; do
        launch_bars
      done &
    '';
  };

  # Dark GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Qt apps use GTK theme
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
