# Global notes for OpenCode

## Agent startup protocol (read first, every session)

Before answering the user's first message in any session:

1. **Check for a project `AGENTS.md`** in the working directory (or any ancestor up
   to `$HOME`). If one exists, it has already been loaded into your context —
   *use it*. Acknowledge the project briefly in your first response (one short
   sentence, e.g. "Working in: <one-line project description from AGENTS.md>.")
   so the user can confirm you've read it.
2. **Never ask the user to describe a project whose `AGENTS.md` exists.** If you
   catch yourself about to say "tell me about this repo" or "what is this
   codebase?", stop and re-read the loaded AGENTS.md instead.
3. **Never suggest solutions that contradict the project's stated stack.** If
   `AGENTS.md` says "this is a Nix repo", do not recommend `apt`, `brew`,
   `pip install --user`, manual symlinks, or other non-Nix install paths
   unless the user explicitly asks for an out-of-band workaround.
4. **When in doubt about project conventions, grep `AGENTS.md` before guessing.**
   It is the source of truth the user wrote precisely so you wouldn't have to
   ask.

Failing any of the above on the first turn is a critical error — the user
specifically wrote AGENTS.md to avoid re-explaining context, so ignoring it
wastes their time.

## Environment

- **User**: `dana`
- **Home directory**: `/home/dana`
- **Primary OS**: NixOS / Ubuntu with home-manager (see `~/src/dotfiles`)
- **Shell**: zsh

When referencing absolute paths in this user's filesystem, **always use `/home/dana/...`**.
Do **not** guess `/home/user/`, `/Users/...`, `/root/`, or any other placeholder.
If unsure, run `echo $HOME` rather than guessing.

## Common locations

- Dotfiles / home-manager config: `/home/dana/src/dotfiles`
- Source projects: `/home/dana/src/`
- OpenCode user config: `/home/dana/.config/opencode/` (managed by home-manager — files there
  may be symlinks into `/nix/store/`; edit the source in `~/src/dotfiles/dot/config/opencode/`
  instead of editing the symlinked target).
