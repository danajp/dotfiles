# Refactor Checklist

Copy this file to `REFACTOR_CHECKLIST.md` (gitignored) and use it as a
working scratchpad while refactoring. Tick boxes as you go; commit
between waves so each wave is bisectable.

## Pre-flight (do once)

- [ ] Working tree is clean (`git status`)
- [ ] On a refactor branch (`git checkout -b refactor/home-manager`)
- [ ] Baseline snapshotted: `make snapshot`
- [ ] Both hosts build cleanly: `make build-all`
- [ ] `make verify` passes against unmodified code

## Per-wave workflow

After each refactor change:

- [ ] `make verify` passes (check, test, lint, build-all, diff)
- [ ] If diff is non-empty, every change is **intended** and **explained**
- [ ] One commit per logical refactor (not per file)
- [ ] Commit message names the suggestion # being addressed
- [ ] Spot-check matrix below run after `home-manager switch`

## Spot-check matrix (after `home-manager switch`)

Run on the host you switched to. Don't switch on a second host until
the first is fully verified.

### Window manager

- [ ] `Mod4+Return` opens ghostty
- [ ] `Mod4+Shift+Return` opens default browser
- [ ] `Mod4+space` opens rofi (drun mode)
- [ ] `Mod4+Shift+space` opens rofi (run mode)
- [ ] `Mod4+Ctrl+space` opens rofi (window mode)
- [ ] `Mod4+Shift+e` opens power menu
- [ ] `Mod4+Escape` locks session
- [ ] `Mod4+1` through `Mod4+0` switch workspaces 1..10
- [ ] `Mod4+Ctrl+1` through `Mod4+Ctrl+9` switch to workspaces 11..19
- [ ] Workspace 5 lands on external monitor (when docked)
- [ ] Workspace 1 lands on internal monitor
- [ ] `Mod4+t` toggles layout
- [ ] `Mod4+f` fullscreens
- [ ] `Mod4+r` enters resize mode; arrow keys resize; Escape exits

### Polybar

- [ ] Bar visible on every connected monitor
- [ ] i3 workspaces module renders correctly (focused/unfocused colors)
- [ ] xwindow module shows focused window title
- [ ] net-traffic module shows up/down speeds
- [ ] bluetooth module appears when bluetooth is on
- [ ] vpn module appears when VPN is connected (skip if not testing VPN)
- [ ] cpu, memory modules update
- [ ] battery module shows percentage and correct charging state
- [ ] pulseaudio module updates when volume changes
- [ ] time-utc and time-local both render
- [ ] Tray shows nm-applet, copyq, dunst, etc.

### Hardware keys

- [ ] `XF86AudioRaiseVolume` increases volume + plays click sound
- [ ] `XF86AudioLowerVolume` decreases volume
- [ ] `XF86AudioMute` toggles mute
- [ ] `XF86MonBrightnessUp` increases brightness
- [ ] `XF86MonBrightnessDown` decreases brightness

### Theming

- [ ] `toggle-colors dark` flips GTK theme to Adwaita-dark
- [ ] `toggle-colors dark` flips emacs theme (if emacs is running)
- [ ] `toggle-colors light` reverts both
- [ ] Brave follows system color scheme (after toggle)
- [ ] Slack follows system color scheme

### Browsers / apps

- [ ] `brave --version` shows pinned version (1.87.x)
- [ ] Brave launches without sandbox errors
- [ ] Slack launches and connects
- [ ] 1Password GUI launches
- [ ] Signal Desktop launches

### Git / GitHub

- [ ] `git lg` alias works
- [ ] `git config --get user.email` returns the noreply address
- [ ] A real signed commit succeeds (commit something trivial, then revert)
- [ ] `gh auth status` works

### Terminal / shell

- [ ] Ghostty opens with correct font, size, theme
- [ ] Tmux starts; powerline status renders
- [ ] Starship prompt shows the configured segments

### Display / monitors (test ON the actual machine)

- [ ] Plug external monitor → autorandr "docked" profile activates
- [ ] Unplug external monitor → autorandr "undocked" profile activates
- [ ] i3 restarts after profile switch (workspaces re-distribute)

### Services

- [ ] `systemctl --user status polybar` is active
- [ ] (thinkpad) `systemctl --user status xmodmap-printscreen` ran ok
- [ ] (thinkpad) PrintScreen key acts as Super_R after resume

### Login / session

- [ ] GDM still shows "i3 (Home Manager)" session entry
- [ ] Logging in to that entry boots i3 cleanly

## Wave-by-wave plan

Tick after wave's `make verify` AND spot-checks pass on at least one host.

- [ ] **Wave 1**: Module split (#1, #2) — pure refactor, byte-diff must be empty
- [ ] **Wave 2**: Empty-string deletions, dead code (#10) — pure refactor
- [ ] **Wave 3**: Solarized palette extraction (#4) — pure refactor
- [ ] **Wave 4**: Workspace generator (#5) — pure refactor, `make test` covers it
- [ ] **Wave 5**: `writeShellApplication` (#6) — output changes (shellcheck wrapper); spot-check each script
- [ ] **Wave 6**: Hardcoded path fixes (#7) — output changes; spot-check polybar modules + i3 startup
- [ ] **Wave 7**: `my.monitors` option (#3) — pure refactor IF mkWorkspaceOutputs is byte-identical to old extraConfig
- [ ] **Wave 8**: Flake refactor + brave overlay (#9) — closure may shift; verify brave version
- [ ] **Wave 9**: Misc hygiene (#11, #12) — tiny changes, easy to verify

## Rollback procedure

If something is broken after `home-manager switch`:

```bash
# List generations
home-manager generations | head -3

# Activate the previous generation
/nix/store/<previous-gen-hash>-home-manager-generation/activate

# Or git revert and re-switch
git revert <bad-commit>
home-manager switch --flake .#dana@<host>
```

## Done criteria

- [ ] All waves complete
- [ ] Both hosts spot-checked
- [ ] Lived with the new config for at least 24h on each host
- [ ] Branch merged to main
- [ ] Baseline updated: `make snapshot` (re-baseline post-refactor)
