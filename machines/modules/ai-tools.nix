# AI coding assistants: opencode + claude-code
{ pkgs, ... }:

let
  dcg = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "destructive-command-guard";
    version = "0.5.7";

    src = pkgs.fetchurl {
      url = "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v${version}/dcg-x86_64-unknown-linux-musl.tar.xz";
      hash = "sha256-PLcpeskKAbguYWW17gp0uLZzJQ5KCrkYLV2+OWpGfN4=";
    };

    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.gnutar
      pkgs.xz
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin"
      tar -xJf "$src" -C "$out/bin" dcg
      chmod +x "$out/bin/dcg"

      runHook postInstall
    '';

    meta = {
      description = "Pre-execution guard that blocks destructive AI shell commands";
      homepage = "https://github.com/Dicklesworthstone/destructive_command_guard";
      license = pkgs.lib.licenses.mit;
      mainProgram = "dcg";
      platforms = [ "x86_64-linux" ];
    };
  };
in

{
  programs.opencode = {
    enable = true;

    # Keep dcg scoped to opencode so the plugin can find it without making it a
    # general shell dependency.
    extraPackages = [ dcg ];

    context = ./ai-tools/AGENTS.md;

    settings = {
      plugin = [
        "@opencode-ai/plugin"
        "oh-my-openagent"
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

  xdg.configFile = {
    "dcg/config.toml".source = ./ai-tools/dcg-config.toml;
    "opencode/plugins/dcg-guard.js".text = builtins.replaceStrings [ "@dcg@" ] [ "${dcg}/bin/dcg" ] (
      builtins.readFile ./ai-tools/dcg-guard.js
    );
  };
}
