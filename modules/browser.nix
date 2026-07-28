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

  # 1Password Okta / SSO sign-in handler.
  #
  # When signing in to an Okta-federated account, 1Password's web flow
  # redirects the browser to an `onepassword://sso/oidc/redirect?...` deep
  # link so the desktop app can finalize the SSO handshake (the app's
  # `captureUrl` classifies it as `SsoRedirect`).
  #
  # Brave hands external schemes to xdg-desktop-portal's OpenURI, and the
  # portal launches the registered handler's `Exec` command. Under our i3
  # session the portal's PATH is the bare login PATH (/usr/bin etc.) with NO
  # ~/.nix-profile/bin on it, so a handler whose Exec is the bare word
  # `1password` fails to launch — the portal reports "No Apps available".
  # (The upstream 1password.desktop hits exactly this: its Exec is
  # `1password %U`.)
  #
  # Fix: ship our own handler whose Exec is the ABSOLUTE store path to the
  # binary, so it launches regardless of the portal's PATH. Interpolating
  # `${pkgs._1password-gui}` tracks store-hash updates automatically. We also
  # declare `onepassword8` (a second scheme the app accepts) for completeness.
  # Fully declarative — no root, no `setup/` helper.
  #
  # NOTE: the portal caches the handler database at startup, so after a
  # `home-manager switch` that changes this entry you must restart the portal
  # for it to take effect:
  #   systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk
  xdg.desktopEntries."1password-schemes" = {
    name = "1Password (URL scheme handler)";
    genericName = "Password Manager";
    comment = "Password manager and secure wallet";
    exec = "${pkgs._1password-gui}/bin/1password %U";
    icon = "1password";
    type = "Application";
    terminal = false;
    categories = [ "Office" ];
    # Handler-only entry; hide it from application menus/launchers.
    noDisplay = true;
    mimeType = [
      "x-scheme-handler/onepassword"
      "x-scheme-handler/onepassword8"
    ];
    settings.StartupWMClass = "1Password";
  };

  # Enabling xdg.mimeApps makes home-manager manage ~/.config/mimeapps.list
  # (as a read-only symlink), so ALL desired defaults must be declared here
  # or they'll be dropped. The browser/mail/slack associations below mirror
  # the pre-existing hand-written file; the onepassword* entries are the SSO
  # fix.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
      "x-scheme-handler/mailto" = "brave-browser.desktop";
      "x-scheme-handler/slack" = "slack.desktop";
      "x-scheme-handler/onepassword" = "1password-schemes.desktop";
      "x-scheme-handler/onepassword8" = "1password-schemes.desktop";
    };
  };
}
