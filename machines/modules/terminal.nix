# Terminal emulator (ghostty) + application launcher (rofi)
{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "dark:iTerm2 Solarized Dark,light:iTerm2 Solarized Light";
      font-family = "Inconsolata";
      font-size = 12.0;
      window-decoration = "none";
      mouse-scroll-multiplier = 0.5;
      app-notifications = "no-clipboard-copy";
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "Inconsolata 14";
    theme = "solarized-dark";
    extraConfig = {
      modi = "drun,run,window,ssh";
      show-icons = true;
      icon-theme = "Adwaita";
      drun-display-format = "{name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
      display-ssh = "SSH";
    };
  };

  # Rofi solarized-dark theme (sourced from dot/)
  xdg.configFile = {
    "rofi/solarized-dark.rasi".source = ../../dot/config/rofi/solarized-dark.rasi;
    "rofi/power-menu.rasi".source = ../../dot/config/rofi/power-menu.rasi;
  };
}
