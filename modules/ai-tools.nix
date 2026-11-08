# AI coding assistants: opencode + claude-code
{ pkgs, lib, ... }:

let
  # Voice dictation: https://github.com/renjfk/opencode-voice
  # 1.x targets the OpenCode 2 plugin API. Patched so transcript cleanup runs
  # through opencode's own providers (reusing its Anthropic auth, no API key), so
  # the unused TTS half doesn't bind escape, and so the STT keybinds are configurable.
  opencodeVoice = pkgs.stdenvNoCC.mkDerivation {
    pname = "opencode-voice";
    version = "1.0.0";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@renjfk/opencode-voice/-/opencode-voice-1.0.0.tgz";
      hash = "sha256-LS1dPXmW/BskIdgRzZyJ0ZaeP7BP8efB4+1ftPIeYaI=";
    };
    patches = [ ./ai-tools/opencode-voice.patch ];
    installPhase = "cp -r . $out";
  };

  # The plugin's default model; it looks for it under ~/.local/share/whisper-cpp/.
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin";
    hash = "sha256-OUIhcJzVrR9AxG5gMcphvOiJMebgiMGIKUxtWlX/p+I=";
  };
  omo = import ../lib/omo.nix { inherit pkgs; };
in
{
  # OmO Native: oh-my-openagent's standalone agent CLI (Sisyphus-style
  # delegation via categories). Keeps its own state under ~/.omo; run
  # `omo setup` once to carry API keys, MCP servers and skills over from
  # opencode. OAuth logins can't be copied: `/login anthropic-subscription`.
  home.packages = [ omo ];

  xdg.dataFile."whisper-cpp/ggml-large-v3-turbo-q5_0.bin".source = whisperModel;

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

    # Wrapped so opencode-voice finds its tools on PATH. Done in a wrapper rather
    # than home.packages so they don't leak into the user environment.
    package = pkgs.symlinkJoin {
      # Keep the version in the name: the module gates tui config on it.
      name = "${lib.getName pkgs.opencode}-wrapped-${lib.getVersion pkgs.opencode}";
      inherit (pkgs.opencode) meta;
      version = lib.getVersion pkgs.opencode;
      paths = [ pkgs.opencode ];
      preferLocalBuild = true;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # opencode-voice shells out to sox (recording) and whisper-cli (transcription).
      # Vulkan cuts transcription from ~8s to ~3s on the framework's Radeon 780M, and
      # ggml falls back to CPU where there's no Vulkan device.
      postBuild = ''
        wrapProgram $out/bin/opencode \
          --prefix PATH : ${lib.makeBinPath [ pkgs.sox pkgs.whisper-cpp-vulkan ]}
      '';
    };

    context = ./ai-tools/AGENTS.md;

    # OpenCode 2 terminal-client settings (cli.json; replaces v1's tui.json).
    cli = {
      plugins = [
        {
          package = "${opencodeVoice}";
          options = {
            opencodeModel = "anthropic/claude-haiku-4-5";
            tts = false;
            # Upstream defaults (ctrl+r, <leader>r) collide with session_rename and
            # messages_redo.
            recordKey = "<leader>v";
            submitKey = "<leader>shift+v";
          };
        }
      ];
    };

    settings = {
      # OpenCode 2 key (`plugins`); the v1 `permission` block below is still
      # read and normalized by OpenCode 2.
      # oh-my-openagent is deliberately absent: on OpenCode 2 the plugin loads but
      # none of its agents, tools or hooks are active. Its workflow now lives in
      # the standalone `omo` CLI (see home.packages below).
      plugins = [
        # Claude subscription auth for OpenCode 2, reusing Claude Code's
        # credentials. Replaces opencode-anthropic-oauth, which is v1-only.
        # One-time setup: /connect -> Anthropic -> Import Claude Code subscription.
        # https://github.com/griffinmartin/opencode-claude-auth
        "opencode-claude-auth@latest"
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
        # OpenCode 1 asked by default before touching paths outside the project;
        # OpenCode 2 allows it. Keep the v1 behavior.
        external_directory = "ask";
      };
    };
  };

  programs.claude-code = {
    enable = true;
  };
}
