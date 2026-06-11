# AGENTS.md - Agentic Coding Guidelines

## Agent startup protocol (READ FIRST)

This file is loaded into your context automatically by OpenCode at session
start. Before responding to the user's first message:

1. **Acknowledge the project** in your first response with one short sentence,
   e.g. "Working in: Nix/Home Manager dotfiles for thinkpad + framework
   laptops." This proves to the user you've read this file.
2. **Never ask "what is this repo?"** — the answer is right here.
3. **Never suggest non-Nix install paths** (`apt install`, `brew`, `pip install
   --user`, manual `~/.bashrc` edits, hand-symlinked dotfiles, etc.) unless
   the user explicitly asks for an out-of-band workaround. See "Where does X
   belong?" below for the canonical placement of new additions.
4. **Editing config under `~/.config/`** that is symlinked into `/nix/store/`
   does nothing useful. The chain is:
   `~/.config/<X>` → `/nix/store/<hash>-home-manager-files/.config/<X>` →
   source file in this repo. Edit the **source** (`modules/<topic>/<asset>`
   or wherever the HM option points) and run `home-manager switch` to apply.

Failing any of these on the first turn is a critical error.

## ⚠️ Active reorganization: moving away from `dot/`

This repo is **actively migrating** from a pre-home-manager layout (a top-level
`dot/` dir holding raw dotfiles, symlinked by `Makefile`) to a home-manager-native
layout where every asset lives next to the module that consumes it under
`modules/<topic>/`.

- ✅ **New additions** go in `modules/<topic>/` — both the `.nix` module
  and any static assets it references (e.g.
  `modules/ai-tools/AGENTS.md`).
- ⚠️ **Existing files still under `dot/`** are mid-migration. Don't reflexively
  add new files there. When touching a file under `dot/`, consider whether it
  should move into a `modules/<topic>/` directory as part of the change.
- ❌ **The `Makefile` and its symlink-based install are deprecated.** Do not
  suggest `make install` or hand-symlinking. Everything goes through
  `home-manager switch`.

## Configuration placement preference (strict order)

When adding new configuration, prefer earlier options over later ones:

1. **Typed home-manager option** — `programs.<name>.<option>` or
   `services.<name>.<option>`. Example: `programs.opencode.context = ./AGENTS.md;`.
   This is always preferred when an HM module exists for the tool.
2. **`xdg.configFile."path".source` / `home.file."path".source`** — for tools
   without an HM module, point at a source file colocated with its module.
3. **`xdg.configFile."path".text`** — for short, generated-from-nix content.
4. **Hand-rolled symlinks or `home.activation` scripts** — last resort, only
   when the above options genuinely don't fit.

Never reach for option 4 if option 1 is available — that's almost always a sign
the tool has an HM module you haven't found yet.

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
├── flake.nix                          # Entry point - defines system configurations
├── hosts/                             # Machine-specific entry points ONLY
│   ├── thinkpad.nix                   # Machine-specific: thinkpad
│   └── framework.nix                  # Machine-specific: framework
├── common.nix                         # Shared Home Manager config (packages, etc.)
├── i3.nix                             # i3 window manager configuration
├── scripts/                           # Nix-evaluated helper scripts
├── modules/                           # Topical HM modules (the canonical home for shared config)
│   ├── default.nix                    # Aggregate import of all topical modules
│   ├── ai-tools.nix                   # opencode + claude-code
│   ├── ai-tools/                      # Assets consumed by ai-tools.nix
│   │   ├── AGENTS.md                  # Global opencode context
│   │   └── oh-my-openagent-*.json     # Per-machine agent configs
│   ├── browser.nix
│   ├── git.nix
│   ├── polybar.nix
│   ├── shell.nix
│   ├── terminal.nix
│   └── theming.nix
├── bin/                               # User shell scripts (installed via HM)
├── lib/                               # Shared nix helpers, called via import (e.g. colors.nix, volume.nix)
├── dot/                               # ⚠️ Legacy: being migrated to modules/<topic>/
└── Makefile                           # ❌ Deprecated - do not use
```

Only genuinely machine-specific entry points live under `hosts/`. Everything
shared lives at the repo root.

### Module vs. helper: which directory?

The split between `modules/` and `lib/` is **by kind of Nix file**, not by
whether the file is "shared":

- **`modules/<topic>.nix` — Home Manager modules.** Signature takes the module
  args (`{ config, pkgs, lib, ... }:`) and the body returns HM *options*
  (`programs.*`, `services.*`, `home.*`). Consumed by being listed in an
  `imports = [ ... ]` (see `modules/default.nix`). Example: `terminal.nix`.
- **`lib/<name>.nix` — called helpers.** Plain functions (`{ pkgs }:` or
  `{ lib }:`) that return a *value* — a derivation, a string, a function. They
  are never in an `imports` list; they're `import`-ed and **called** at a use
  site. Examples: `volume.nix` (returns a `writeShellScriptBin` derivation,
  called from `i3.nix`), `colors.nix`, `i3-workspaces.nix`.

Rule of thumb: if it goes in `imports`, it's a module → `modules/`. If you
`import ./x.nix { ... }` and use the result, it's a helper → `lib/`.

The **module + colocated-assets** pattern (see `modules/ai-tools/`) is
the target layout for modules. New topical modules should follow it: create
`modules/<topic>.nix` plus a sibling `modules/<topic>/`
directory for any static assets it references.

## Key Conventions

1. **Machine configs**: Always import `../common.nix`, add machine-specific overrides
2. **Topical modules**: Group related config under `modules/<topic>.nix`
   and import from machine files; colocate static assets in `modules/<topic>/`
3. **Color scheme**: Consistently use Solarized Dark across all configs (palette
   in `lib/colors.nix`)
4. **Secrets**: Never commit secrets; use `~/.gitconfig-signing` and `~/secrets/`
5. **Packages**: Prefer Nix packages over system packages when available
6. **File moves**: Use `git mv` (not `mv`) so history follows the file
7. **Documentation**: Add inline comments for non-obvious configuration choices

## Testing Changes

```bash
# Full HM evaluation - catches option deprecations, type errors, missing inputs.
# This is the strongest local check; run it before claiming a change works.
home-manager build --flake .#dana@thinkpad
home-manager build --flake .#dana@framework   # ALSO run this if you touched
                                              # anything in common.nix
                                              # or modules/

# Lighter syntax-only check (won't catch HM module issues)
nix flake check

# Inspect what would actually land in $HOME after a build
ls -la result/home-files/.config/<some-path>
cat result/home-files/.config/<some-path>
```

**Rule**: If you touched shared code (`common.nix` or anything in `modules/`),
build BOTH machine configs. A working thinkpad build does not imply a working
framework build.

## Where does X belong?

| What you're adding | Canonical location | How to wire it |
|---|---|---|
| Package available in nixpkgs | `home.packages` in `common.nix` (or a host file if host-specific) | `home.packages = [ pkgs.<name> ];` |
| Tool with a home-manager module | New or existing `modules/<topic>.nix` | `programs.<name>.enable = true;` + typed options |
| Static asset consumed by an HM option | `modules/<topic>/<asset>` | Pass via the typed option (e.g. `context = ./<topic>/asset.md;`) |
| Static config file with no HM module | `modules/<topic>/<asset>` | `xdg.configFile."path".source = ./<topic>/<asset>;` |
| User shell script | `bin/<script>` | Installed via existing HM wiring (see `bin/` references in `common.nix`) |
| Per-machine override | `hosts/<host>.nix` | After `imports = [ ../common.nix ];` |
| Shared across machines | `common.nix` or a module imported by both machines | Plain HM options |
| Color/theme constants | `lib/colors.nix` | `let palette = import ../../lib/colors.nix; in ...` |

If the answer to "where does X belong?" isn't on this table, the convention
isn't established yet — ask the user before inventing one.

## Home-manager option gotchas

- Options get **renamed across HM releases**. If `home-manager build` prints
  `the option 'programs.X.Y' has been renamed to 'programs.X.Z'`, update the
  call site immediately — don't ignore the warning. Recent examples:
  `programs.opencode.rules` → `programs.opencode.context`,
  `programs.claude-code.memory.*` → `programs.claude-code.context`.
- The **`home-manager build` output** symlinks at `./result` are inspectable.
  Use them to verify: "did my change actually produce the file I expected at
  the path I expected, with the content I expected?"

## Dependencies

- Nix package manager with flakes enabled
- Home Manager
- Linux system with i3-compatible desktop environment
