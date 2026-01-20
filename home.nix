{ config, pkgs, ... }:

{
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
    pkgs.devenv
    pkgs.git
    pkgs.opencode
    pkgs.claude-code
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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
      plugin = ["opencode-gemini-auth@latest"];
      mode.plan.model = "anthropic/claude-opus-4-5-20251101";
      mode.build.model = "anthropic/claude-sonnet-4-20250514";
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

  home.file.".asdfrc".source = ./dot/asdfrc;
  home.file.".gemrc".source = ./dot/gemrc;

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
}
