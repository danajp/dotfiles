# GTK + Qt theming and XDG desktop portal preference.
#
# We use Adwaita-dark for both GTK and Qt to keep apps visually
# consistent. The XDG portal is configured to use the GTK backend
# so X11 apps (Brave, Slack, Ghostty) follow gsettings color-scheme
# changes on i3 (where there's no built-in portal).
{ config, pkgs, ... }:

{
  # Dark GTK theme
  gtk = {
    enable = true;
    # Use null to let gsettings control GTK4 theming (via toggle-colors script)
    gtk4.theme = null;
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

  # XDG desktop portal: use the GTK backend for Settings (color-scheme)
  # so that Brave, Slack, and Ghostty follow gsettings color-scheme changes on i3
  xdg.configFile."xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    default=gtk
  '';
}
