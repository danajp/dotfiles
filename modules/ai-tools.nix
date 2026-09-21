# AI coding assistants: opencode + claude-code
{ pkgs, lib, config, ... }:

{
  # opencode discovers skills at $XDG_CONFIG_HOME/opencode/skill/<name>/SKILL.md.
  # The home-manager programs.opencode module only wires commands/agents/themes,
  # not skills, so link the whole skills directory in ourselves. `recursive = true`
  # so every skill (and any supporting files) is picked up automatically — drop a
  # new skill under ./ai-tools/skills/ and it appears without touching this file.
  xdg.configFile."opencode/skill" = {
    source = ./ai-tools/skills;
    recursive = true;
  };

  programs.opencode = {
    enable = true;

    # opencode-anthropic-oauth reports a claude-cli version to Anthropic, defaulting
    # to one frozen at the plugin's release; too old and fable rejects the session.
    # Wrapped rather than set via home.sessionVariables because those self-guard
    # against re-sourcing, so sessions predating the switch never see new vars.
    package = pkgs.symlinkJoin {
      # Keep the version in the name: the module gates tui config on it.
      name = "${lib.getName pkgs.opencode}-wrapped-${lib.getVersion pkgs.opencode}";
      inherit (pkgs.opencode) meta;
      version = lib.getVersion pkgs.opencode;
      paths = [ pkgs.opencode ];
      preferLocalBuild = true;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/opencode \
          --set-default ANTHROPIC_CLI_VERSION ${config.programs.claude-code.package.version}
      '';
    };

    context = ./ai-tools/AGENTS.md;

    tui = {
      plugin = [
        "oh-my-openagent/tui"
      ];
    };

    settings = {
      plugin = [
        "@opencode-ai/plugin"
        "oh-my-openagent@latest"
        # https://github.com/shahidshabbir-se/opencode-anthropic-oauth/tree/master
        "opencode-anthropic-oauth"
      ];

      permission = {
        bash = {
          # Force-pushing git (direct and via gh)
          "git push *--force*" = "ask";
          "git push *-f *" = "ask";
          "git push *-f" = "ask";
          "git push *--force-with-lease*" = "ask";
          "gh *--force*" = "ask";

          # Terraform state-changing operations
          "terraform apply*" = "ask";
          "terraform destroy*" = "ask";
          "terragrunt apply*" = "ask";
          "terragrunt destroy*" = "ask";
          "tofu apply*" = "ask";
          "tofu destroy*" = "ask";

          # kubectl mutations (and the common `k` alias)
          "kubectl delete*" = "ask";
          "kubectl edit*" = "ask";
          "kubectl patch*" = "ask";
          "kubectl apply*" = "ask";
          "kubectl replace*" = "ask";
          "kubectl scale*" = "ask";
          "kubectl rollout *" = "ask";
          "kubectl cordon*" = "ask";
          "kubectl drain*" = "ask";
          "kubectl taint*" = "ask";
          "kubectl label*" = "ask";
          "kubectl annotate*" = "ask";
          "kubectl create*" = "ask";
          "kubectl set*" = "ask";
          "kubectl exec*" = "ask";
          "k delete*" = "ask";
          "k edit*" = "ask";
          "k patch*" = "ask";
          "k apply*" = "ask";
          "k replace*" = "ask";
          "k scale*" = "ask";

          # Reading .env files via common viewers
          "cat *.env" = "ask";
          "cat *.env.*" = "ask";
          "cat *.env *" = "ask";
          "less *.env*" = "ask";
          "bat *.env*" = "ask";
          "head *.env*" = "ask";
          "tail *.env*" = "ask";
          "cp *.env*" = "ask";

          # Reading SSH private keys
          "cat *.ssh/*" = "ask";
          "cat *id_rsa*" = "ask";
          "cat *id_ed25519*" = "ask";
          "cat *id_ecdsa*" = "ask";
          "cat *id_dsa*" = "ask";
          "less *.ssh/*" = "ask";
          "bat *.ssh/*" = "ask";
          "* ~/.ssh/*" = "ask";
          "* /home/dana/.ssh/*" = "ask";

          # Everything else: allow without prompting
          "*" = "allow";
        };

        # The `read` tool bypasses bash, so gate sensitive paths here too
        read = {
          "**/.env" = "ask";
          "**/.env.*" = "ask";
          "**/*.env" = "ask";
          "~/.ssh/**" = "ask";
          "/home/dana/.ssh/**" = "ask";
          "**/id_rsa*" = "ask";
          "**/id_ed25519*" = "ask";
          "**/id_ecdsa*" = "ask";
          "**/id_dsa*" = "ask";
          "**/*.pem" = "ask";
          "**/*.key" = "ask";
          "**" = "allow";
        };

        edit = "allow";
        webfetch = "allow";
      };
    };
  };

  programs.claude-code = {
    enable = true;
  };
}
