# Shell environment: tmux multiplexer + starship prompt
{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    mouse = true;
    historyLimit = 20000;
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = power-theme;
        extraConfig = ''
          run-shell "powerline-daemon -q"
          source ${pkgs.powerline}/share/tmux/powerline.conf
        '';
      }
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = ''
        $kubernetes$directory$git_branch$git_status$aws$direnv$nix_shell$cmd_duration$fill$time''${custom.local_time}$line_break$character
      '';
      kubernetes.disabled = false;
      ruby.disabled = true;
      nodejs.disabled = true;
      gcloud.disabled = true;
      golang.disabled = true;
      python.disabled = true;
      package.disabled = true;
      terraform.disabled = true;
      vagrant.disabled = true;
      aws.region_aliases = {
        us-east-1 = "use1";
        us-west-2 = "usw2";
        eu-central-1 = "euc1";
        eu-west-1 = "euw1";
        ap-southeast-2 = "apse2";
        ap-southeast-4 = "apse4";
      };
      time = {
        disabled = false;
        utc_time_offset = "0";
        time_format = "%T UTC";
        format = "[$time]($style) ";
      };
      custom.local_time = {
        description = "show local time";
        when = true;
        command = "date +'%T %Z'";
        format = "[$output]($style)";
      };
      fill.symbol = " ";
      direnv.disabled = false;
    };
  };
}
