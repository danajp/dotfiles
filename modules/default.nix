# Aggregate import for all topical modules. Importing this module
# pulls in every concern that used to live in common.nix.
{
  imports = [
    ./ai-tools.nix
    ./browser.nix
    ./datadog-pup.nix
    ./git.nix
    ./polybar.nix
    ./scripts.nix
    ./shell.nix
    ./terminal.nix
    ./theming.nix
  ];
}
