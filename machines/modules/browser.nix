# Brave browser, pinned to a specific nixpkgs revision via pkgs-brave.
# The pin is necessary because Brave releases break frequently in
# nixos-unstable; we hold at a known-good version.
{ pkgs-brave, ... }:

{
  programs.brave = {
    enable = true;
    package = pkgs-brave.brave;
    extensions = [
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
    ];
  };
}
