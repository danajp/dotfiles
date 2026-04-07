# AGENTS.md - Agentic Coding Guidelines

## Repository Overview

**Type**: Nix/Home Manager dotfiles repository
**Purpose**: Reproducible Linux desktop environment configuration using Nix flakes and Home Manager

## Build & Deploy Commands

```bash
# Apply Home Manager configuration (deploy changes)
home-manager switch --flake .#dana@thinkpad     # For thinkpad
home-manager switch --flake .#dana@framework    # For framework

# Validate flake without applying
nix flake check

# Update flake.lock
nix flake update

# Format nix files
nix fmt

# Legacy symlink-based install (deprecated)
make install    # or: make scripts / make dots
```

## Code Style Guidelines

### Nix Files (.nix)

- **Indentation**: 2 spaces (no tabs)
- **Line length**: Keep under 100 characters when practical
- **Formatting**: Run `nix fmt` before committing
- **Imports**: Group at top, local paths use relative imports (e.g., `./common.nix`)
- **Let bindings**: Use for computed values, place before `in`
- **Comments**: Use `#` for single-line comments, describe "why" not "what"

```nix
# Good
{ config, pkgs, ... }:

let
  monitorName = "eDP-1";
in
{
  imports = [ ./common.nix ];

  programs.git = {
    enable = true;
    settings.user.name = "Dana";
  };
}
```

### Shell Scripts (bin/)

- **Shebang**: Use `#!/bin/bash` or `#!/usr/bin/env bash`
- **Strict mode**: Always include `set -eo pipefail` at top
- **Functions**: Use `snake_case`, include `local` for variables
- **Error handling**: Use `fatal()` helper pattern for error messages
- **Indentation**: 2 spaces
- **Quotes**: Quote all variable expansions: `"$var"` not `$var`

```bash
#!/bin/bash
set -eo pipefail

fatal() {
  echo "$@" >&2
  exit 1
}

main() {
  local repo_url="$1"

  if [[ -z "$repo_url" ]]; then
    fatal "repo_url is required"
  fi
}

main "$@"
```

### i3 Configuration

- Use machine-specific monitor variables (e.g., `${internalMonitor}`)
- Solarized Dark color palette (see common.nix for hex values)
- Comment format: `# ── Section Name ───────────────────────`
- Key bindings follow i3 conventions (Mod4 = Super/Windows)

## Project Structure

```
.
├── flake.nix              # Entry point - defines system configurations
├── machines/
│   ├── common.nix         # Shared Home Manager config
│   ├── i3.nix            # i3 window manager configuration
│   ├── thinkpad.nix      # Machine-specific: thinkpad
│   └── framework.nix     # Machine-specific: framework
├── bin/                   # Custom shell scripts
├── dot/                   # Static dotfiles
│   ├── bashrc
│   ├── zshrc
│   └── config/           # XDG config files (i3, rofi, etc.)
└── Makefile              # Legacy installation (deprecated)
```

## Key Conventions

1. **Machine configs**: Always import `./common.nix`, add machine-specific overrides
2. **Color scheme**: Consistently use Solarized Dark across all configs
3. **Scripts**: Install via `home.file` or symlink in `~/bin/`
4. **Secrets**: Never commit secrets; use `~/.gitconfig-signing` and `~/secrets/`
5. **Packages**: Prefer Nix packages over system packages when available
6. **Documentation**: Add inline comments for non-obvious configuration choices

## Testing Changes

```bash
# Test Home Manager build without switching
home-manager build --flake .#dana@thinkpad

# Check nix syntax
nix-instantiate --eval --strict machines/common.nix
```

## Common Tasks

- **Add new package**: Add to `home.packages` in `machines/common.nix`
- **Add new script**: Create in `bin/`, will be symlinked via Makefile
- **Add dotfile**: Place in `dot/`, reference via `home.file` or `xdg.configFile`
- **Machine-specific config**: Add to appropriate `machines/*.nix`

## Dependencies

- Nix package manager with flakes enabled
- Home Manager
- Linux system with i3-compatible desktop environment
