# Common Home Manager configuration shared across all machines.
#
# Identity, package list, session variables, and the toggle-colors helper
# live here. Topical concerns (git, shell, terminal, browser, polybar,
# theming, ai-tools) live under ./modules/ and are pulled in via
# ./modules/default.nix.
{ pkgs, ... }:

{
  imports = [
    ./i3.nix
    ./modules
  ];
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

    (pkgs.writeShellScriptBin "toggle-colors"
      (builtins.readFile ./scripts/toggle-colors.sh))
    pkgs._1password-gui
    pkgs.slack
  ];

  programs.bun.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.file.".asdfrc".source = ../dot/asdfrc;
  home.file.".gemrc".source = ../dot/gemrc;

  # XDG config files
  xdg.enable = true;
}
