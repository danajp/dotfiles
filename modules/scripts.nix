# Personal scripts, installed onto PATH via `pkgs.writeShellApplication`.
#
# writeShellApplication runs shellcheck at build time and prepends each
# script's `runtimeInputs` to PATH, so its tools resolve from the Nix
# store. PATH is prepended (not replaced), so host-only tools like
# emacsclient, regolith-look, gnome-control-center and getent still work
# without being listed here.
#
# This installs the "package-like" scripts in ../bin — tools meant to be
# run from anywhere, like any other installed program. Repo tooling lives
# in ../ci and system-mutation installers in ../setup; neither is
# installed on PATH (see those dirs).
#
# Each script is declared explicitly below. Its body lives in ../bin and
# is read in with `builtins.readFile`. To add a script: drop the file in
# ../bin, `git add` it (flakes only see tracked files), and add one line
# here.
{ pkgs, ... }:

let
  # Scripts carry their own `set -eo pipefail` and handle optional
  # positional args, so don't inject writeShellApplication's default
  # `nounset` (it would break scripts that reference an unset "$2").
  mkScript =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      bashOptions = [ ];
      text = builtins.readFile (../bin + "/${name}");
    };
in
{
  home.packages = with pkgs; [
    (mkScript "argocd-remove-deleted-app-hook-finalizers" [ kubectl jq gawk ])
    (mkScript "backup-home" [ gnutar gzip ])
    (mkScript "clone-gh" [ git gawk ])
    (mkScript "create-test-branch" [ git ])
    (mkScript "fix-audio" [ pulseaudio gnugrep gawk ])
    (mkScript "kdebug2" [ kubectl openssl envsubst ])
    (mkScript "list-ingress-lb" [ kubectl jq util-linux coreutils ])
    (mkScript "run-pod" [ kubectl ])
    (mkScript "shot" [ maim xclip coreutils ])
    (mkScript "toggle-colors" [ glib ])
  ];
}
