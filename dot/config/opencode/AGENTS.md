# Global notes for OpenCode

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
