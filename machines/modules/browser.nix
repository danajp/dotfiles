# Brave browser. Pinned to a known-good revision via the overlay in
# flake.nix — `pkgs.brave` already returns the pinned package, so
# `programs.brave.package` could be omitted (HM defaults to pkgs.brave).
# Kept explicit so the dependency on the overlay is visible at the
# call site.
{ pkgs, ... }:

{
  programs.brave = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
    ];
  };
}
