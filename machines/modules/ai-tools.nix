# AI coding assistants: opencode + claude-code
{ ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      plugin = [
        "@opencode-ai/plugin"
        "oh-my-openagent"
        # https://github.com/shahidshabbir-se/opencode-anthropic-oauth/tree/master
        "opencode-anthropic-oauth"
      ];
    };
  };

  programs.claude-code = {
    enable = true;
  };
}
