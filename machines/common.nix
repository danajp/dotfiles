# Common Home Manager configuration shared across all machines.
#
# Identity, package list, session variables, and the toggle-colors helper
# live here. Topical concerns (git, shell, terminal, browser, polybar,
# theming, ai-tools) live under ./modules/ and are pulled in via
# ./modules/default.nix.
{ pkgs, config, ... }:

{
  imports = [
    ./i3.nix
    ./modules
  ];
  # enable gpu on non nixos linux
  # see https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
  targets.genericLinux.gpu.enable = true;
  # Redundant alongside the `config.allowUnfree = true` in flake.nix's
  # pkgs import, but harmless and explicit. HM evaluates this predicate
  # for any unfree package referenced via the module system.
  nixpkgs.config.allowUnfreePredicate = _: true;

  home = {
    # Home Manager needs a bit of information about you and the paths it
    # should manage.
    username = "dana";
    homeDirectory = "/home/dana";

    # This value determines the Home Manager release that your configuration
    # is compatible with. This helps avoid breakage when a new Home Manager
    # release introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If
    # you do want to update the value, then make sure to first check the
    # Home Manager release notes.
    stateVersion = "25.11"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = [
      pkgs.asdf-vm
      pkgs.copyq
      pkgs.devenv
      pkgs.emacs
      pkgs.emacs-lsp-booster
      pkgs.pamixer
      pkgs.powerline
      pkgs.libsecret  # Required for Signal Desktop to access system keyring
      pkgs.signal-desktop
      pkgs.feh
      pkgs.brightnessctl
      pkgs.temporal-cli
      pkgs.input-leap

      (pkgs.writeShellScriptBin "toggle-colors"
        (builtins.readFile ./scripts/toggle-colors.sh))
      pkgs._1password-gui
      pkgs.slack

      # Basic utilities (migrated from bootstrap apt)
      pkgs.gnupg
      pkgs.htop
      pkgs.powertop
      pkgs.curl
      pkgs.sqlite
      pkgs.xclip
      pkgs.traceroute
      pkgs.moreutils
      pkgs.bat

      # Development tools (migrated from bootstrap apt)
      pkgs.cmake
      pkgs.gnumake
      pkgs.python3
      pkgs.ruby
      pkgs.postgresql
      pkgs.redis
      pkgs.graphviz
      pkgs.nmap  # provides ncat
      pkgs.openldap  # provides ldapsearch, etc.
      pkgs.pkg-config

      # Desktop utilities (migrated from bootstrap apt)
      pkgs.arandr
      pkgs.blueman
      pkgs.maim

      # Applications (migrated from bootstrap apt)
      pkgs.zoom-us
      pkgs.mullvad-vpn
      pkgs.ssm-session-manager-plugin
      pkgs.vagrant
      pkgs.spotify
      pkgs.google-cloud-sdk
      pkgs.terraform-ls
      pkgs.openvpn3
      pkgs.docker

      # LSP servers (migrated from npm globals)
      pkgs.yaml-language-server
      pkgs.bash-language-server

      # Fonts (migrated from bootstrap apt)
      pkgs.terminus_font
      pkgs.terminus_font_ttf
      pkgs.inconsolata
      pkgs.noto-fonts-emoji
    ];

    file.".asdfrc".source = ../dot/asdfrc;
    file.".gemrc".source = ../dot/gemrc;

    # asdf default packages (migrated from bootstrap)
    file."/.default-gems".text = ''
      bundler
      solargraph
      solargraph-standardrb
    '';

    file."/.default-python-packages".text = ''
      pipenv
    '';

    file."/.default-golang-pkgs".text = ''
      golang.org/x/tools/gopls@latest
      github.com/rogpeppe/godef@latest
      golang.org/x/tools/cmd/goimports@latest
      github.com/zmb3/gogetdoc@latest
      github.com/maruel/panicparse/v2/cmd/pp@latest
    '';
  };

  programs.bun.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    oh-my-zsh = {
      enable = true;
      plugins = [ "asdf" "direnv" "starship" "git" "z" "kubectl" ];
    };
    shellAliases = {
      k = "kubectl";
      kc = "kubectl config use-context";
      jy = "yj -jy";
      yc = "bat -l yaml --style plain";
      y2i = "ruby -r yaml -r json -e 'puts ({\"items\" => YAML.load_stream(STDIN) }.to_json)'";
      i2y = "ruby -r yaml -r json -e 'puts JSON.parse(STDIN.read)[\"items\"].map {|i| i.to_yaml }.join(\"\")'";
    };
    sessionVariables = {
      EDITOR = "emacsclient";
      ASDF_GOLANG_MOD_VERSION_ENABLED = "true";
    };
    initContent = ''
      add_to_path_if() {
        local dir="$1"
        [[ -d "$dir" ]] && path+=("$dir")
      }

      source_if() {
        local file="$1"
        [[ -e "$file" ]] && source "$file"
      }

      add_to_path_if "$HOME/.asdf/shims"
      add_to_path_if "$HOME/bin"
      add_to_path_if "$HOME/.local/bin"
      add_to_path_if "$HOME/.krew/bin"
      add_to_path_if "$HOME/.cargo/bin"

      if [[ -S "$HOME/.1password/agent.sock" ]]; then
        export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
      fi

      source_if "$HOME/src/work/zsh"
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Run autorandr --change at graphical session start
  services.autorandr.enable = true;

  # Dunst notification daemon (started via D-Bus)
  services.dunst.enable = true;

  # XDG config files
  xdg.enable = true;

  xdg.configFile."dunst/dunstrc".source = ../dot/config/dunst/dunstrc;

  # Direnv config (migrated from bootstrap)
  xdg.configFile."direnv/direnv.toml".text = ''
    [global]
    hide_env_diff = true
    warn_timeout = "30s"
  '';
}
