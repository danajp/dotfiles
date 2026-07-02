# Brave browser. Tracks nixos-unstable like the rest of nixpkgs;
# `programs.brave.package` could be omitted (HM defaults to pkgs.brave)
# but is kept explicit at the call site.
#
# Okta/Duo login needs a managed policy that home-manager cannot write
# (it lives in /etc/brave). Install it once with
# `sudo setup/install-brave-policy`. See README for details.
{ pkgs, ... }:

{
  programs.brave = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
    ];
  };

  # 1Password browser-extension integration: native messaging manifest.
  #
  # The 1Password extension talks to the desktop app over Chrome's native
  # messaging protocol. The desktop package ships a manifest that points at
  # `/opt/1Password/1Password-BrowserSupport`, which doesn't exist on a Nix
  # install — the real binary lives under `${pkgs._1password-gui}/share/...`.
  # We render our own manifest with the correct path. Because the path is
  # interpolated at evaluation time, home-manager rebuilds the file whenever
  # `_1password-gui` is updated; no post-upgrade manual step is needed.
  #
  # The allowed_origins list is copied verbatim from the upstream manifest
  # (the published 1Password extension IDs across Chrome/Firefox/Edge stable
  # and beta channels). The first ID is the one we install via
  # `programs.brave.extensions` above.
  #
  # NOTE: this only handles the per-user manifest. Brave also requires the
  # browser's executable name to appear in /etc/1password/custom_allowed_browsers
  # (a system path home-manager cannot write to). See
  # `setup/install-1password-browser-allowlist`.
  xdg.configFile."BraveSoftware/Brave-Browser/NativeMessagingHosts/com.1password.1password.json".text = builtins.toJSON {
    name = "com.1password.1password";
    description = "1Password BrowserSupport";
    path = "${pkgs._1password-gui}/share/1password/1Password-BrowserSupport";
    type = "stdio";
    allowed_origins = [
      "chrome-extension://aeblfdkhhhdcdjpifhhbdiojplfjncoa/"
      "chrome-extension://hjlinigoblmkhjejkmbegnoaljkphmgo/"
      "chrome-extension://bkpbhnjcbehoklfkljkkbbmipaphipgl/"
      "chrome-extension://gejiddohjgogedgjnonbofjigllpkmbf/"
      "chrome-extension://khgocmkkpikpnmmkgmdnfckapcdkgfaf/"
      "chrome-extension://dppgmdbiimibapkepcbdbmkaabgiofem/"
    ];
  };
}
