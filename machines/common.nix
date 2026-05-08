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
    ];

    file.".asdfrc".source = ../dot/asdfrc;
    file.".gemrc".source = ../dot/gemrc;
  };

  programs.bun.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    oh-my-zsh = {
      enable = true;
      plugins = [ "asdf" "direnv" "starship" "git" "z" ];
    };
    shellAliases = {
      k = "kubectl";
      kc = "kubectl config use-context";
      jy = "yj -jy";
      yc = "batcat -l yaml --style plain";
      y2i = "ASDF_RUBY_VERSION=3.1.2 ruby -r yaml -r json -e 'puts ({\"items\" => YAML.load_stream(STDIN) }.to_json)'";
      i2y = "ASDF_RUBY_VERSION=3.1.2 ruby -r yaml -r json -e 'puts JSON.parse(STDIN.read)[\"items\"].map {|i| i.to_yaml }.join(\"\")'";
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

      source <(kubectl completion zsh)
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
}
