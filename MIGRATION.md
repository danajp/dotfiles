# Migration Checklist: Bootstrap Ansible → Home Manager

Last updated: 2026-05-09

**Goal:** Eliminate as many apt packages as possible by migrating user-level tools to nixpkgs/Home Manager. Only keep apt for things that truly require root or have no nixpkgs equivalent.

---

## Section 1: Move from apt to Home Manager (nixpkgs exists)

### Basic apt packages

These are installed via `apt` in bootstrap but have direct nixpkgs equivalents. Move to `home.packages`.

- [ ] `git` → `pkgs.git`
- [ ] `gnupg` → `pkgs.gnupg`
- [ ] `tmux` → `pkgs.tmux` (already in HM `programs.tmux`, which pulls in the package)
- [ ] `python3-dev` → `pkgs.python3`
- [ ] `postgresql-client` → `pkgs.postgresql`
- [ ] `libpq-dev` → `pkgs.postgresql` (development files)
- [ ] `redis-tools` → `pkgs.redis`
- [ ] `powertop` → `pkgs.powertop`
- [ ] `powerline` → `pkgs.powerline` (already in HM)
- [ ] `ncat` → `pkgs.nmap` (`ncat` is included in the nmap package)
- [ ] `htop` → `pkgs.htop`
- [ ] `traceroute` → `pkgs.traceroute`
- [ ] `xclip` → `pkgs.xclip`
- [ ] `ldap-utils` → `pkgs.openldap` (client tools included)
- [ ] `moreutils` → `pkgs.moreutils`
- [ ] `graphviz` → `pkgs.graphviz`
- [ ] `curl` → `pkgs.curl` (usually already in base system)
- [ ] `sqlite3` → `pkgs.sqlite`
- [ ] `zsh` → `pkgs.zsh` (already in HM `programs.zsh`)
- [ ] `cmake` → `pkgs.cmake`
- [ ] `g++` → `pkgs.gcc` or `pkgs.stdenv.cc` (part of build tools)
- [ ] `pkg-config` → `pkgs.pkg-config`

### Desktop packages

- [ ] `arandr` → `pkgs.arandr`
- [ ] `blueman` → `pkgs.blueman`
- [ ] `copyq` → `pkgs.copyq` (already in HM)
- [ ] `maim` → `pkgs.maim`

### .deb installs

- [ ] `slack-desktop` → `pkgs.slack` (already in HM)
- [ ] `input-leap` → `pkgs.input-leap` (already in HM)
- [ ] `zoom` → `pkgs.zoom-us`
- [ ] `mullvad-vpn` → `pkgs.mullvad-vpn`
- [ ] `aws-session-manager-plugin` → `pkgs.ssm-session-manager-plugin` (attribute name differs)
- [ ] `1password` → `pkgs._1password-gui` (already in HM)

### APT repo packages (from `vars/main.yml`)

- [ ] `brave-browser` → `pkgs.brave` (already in HM via overlay)
- [ ] `signal-desktop` → `pkgs.signal-desktop` (already in HM)
- [ ] `docker-ce` → `pkgs.docker`
- [ ] `google-cloud-cli` → `pkgs.google-cloud-sdk` (attribute name differs)
- [ ] `terraform-ls` → `pkgs.terraform-ls`
- [ ] `openvpn3` → `pkgs.openvpn3`
- [ ] `spotify-client` → `pkgs.spotify`

### Manually downloaded binaries

- [ ] `vagrant` → `pkgs.vagrant`

### Already in HM (don't duplicate)

- [x] `emacs` → `pkgs.emacs`
- [x] `nodejs` → `pkgs.nodejs` (but see note below)
- [x] `dunst` → `pkgs.dunst`
- [x] `rofi` → `pkgs.rofi`

### asdf-managed tools (version switching needed)

Keep in asdf, not apt. See Section 3.

### Move from asdf to nixpkgs (single version sufficient)

- [ ] `python` → `pkgs.python3` (one recent version — drop old 3.6.x/3.7.x, drop asdf)
- [ ] `ruby` → `pkgs.ruby` (recent version only — drop 2.x, drop asdf)

---

## Section 2: Keep in apt (no nixpkgs equivalent, or system-level)

### System-level packages (require root / system integration)

| apt package | Why keep in apt |
|-------------|----------------|
| `openssh-server` | System daemon, needs root |
| `laptop-mode-tools` | **Not in nixpkgs**; system power management |
| `bridge-utils` | Network bridging, typically needs root |
| `hplip-gui` | HP printer setup; could move but needs system cups |
| `virtualbox` | System virtualization, needs kernel modules |
| `policykit-1-gnome` | System polkit agent; your i3 config specifically uses `/usr/lib/policykit-1-gnome/` |

### Other packages with no nixpkgs equivalent

| apt package | nixpkgs status | Notes |
|-------------|----------------|-------|
| `container-linux-config-transpiler` (`ct`) | **Not found** | Project archived 2020. Use `fcct` if still needed. |
| `slackcat` | **Not found** | PR never merged. Alternative: `pkgs.matterhorn` or similar. |
| `duo-desktop` | **Not found** | Only `duo-unix` (PAM module) exists. No GUI client. |

### Fonts

| apt package | nixpkgs equivalent | Notes |
|-------------|-------------------|-------|
| `xfonts-terminus` | `pkgs.terminus_font` | Available |
| `fonts-terminus` | `pkgs.terminus_font_ttf` | Available |
| `fonts-inconsolata` | `pkgs.inconsolata` | Available |
| `fonts-noto-color-emoji` | `pkgs.noto-fonts-emoji` | Available |

**Recommendation:** Move fonts to HM via `home.packages` or `fonts.fontconfig`. NixOS/HM has good font management.

### Config files that need root

These are system-level configs that cannot be moved to HM:

- `/etc/sysctl.d/50-local-disable-ipv6.conf` (IPv6 disable)
- `/etc/apt/preferences.d/disable-snap` (snap disable)
- `/etc/fonts/conf.d/11-powerline-symbols-terminus.conf` (system font config)
- `/etc/sudoers.d/*` (sudoers)
- `/etc/nsswitch.conf` (name service)
- `/etc/opt/chrome/policies/managed/xdg-open.json` (Chrome policy)
- `/etc/NetworkManager/dnsmasq.d/greenhouse-vpn.conf` (VPN DNS)
- `/etc/NetworkManager/dispatcher.d/vpn-update-dnsmasq` (VPN dispatcher)
- `/etc/profile.d/gcloud-set-python.sh` (gcloud env)
- `/etc/xdg/autostart/tracker-miner-fs-3.desktop` (tracker disable)

---

## Section 3: Version-Switching Tools (Keep in asdf)

These need multiple versions. Do **not** install via apt. Use asdf (managed by ansible `user.yaml`).

- [ ] `argo` (pinned to 3.2.8)
- [ ] `golang` (multiple versions)
- [ ] `nodejs` (multiple versions)

---

## Section 4: Drop Entirely

- [ ] ~~`gimp`~~ — Not in HM, don't need
- [ ] ~~`firefox`~~ — Not in HM, don't need (Brave covers browsing)
- [ ] ~~`sloccount`~~ — Removed from nixpkgs; use `loccount` if needed
- [ ] ~~`ruby` 2.4.0–2.6.5~~ — EOL, drop from asdf
- [ ] ~~`python` 3.6.0, 3.6.1, 3.7.5~~ — EOL, drop from asdf
- [ ] ~~Regolith packages~~ — Using vanilla i3 now
- [ ] ~~`alacritty`~~ — Using ghostty now
- [ ] ~~`google-chrome`~~ — Don't need (Brave covers browsing)
- [ ] ~~`leiningen`~~ — Don't need
- [ ] ~~`container-structure-test`~~ — Don't need
- [ ] ~~`slackcat`~~ — Don't need
- [ ] ~~`default-jre`~~ — Don't need
- [ ] ~~`wine`~~ — Don't need
- [ ] ~~`virt-manager` / `libvirt` / `qemu-kvm`~~ — Don't need
- [ ] ~~`openvpn`~~ — Don't need

---

## Section 5: Action Items

### Immediate wins (move to HM, reduce apt)

1. **Move Zoom** from apt `.deb` to `pkgs.zoom-us`
2. **Move Mullvad** from apt `.deb` to `pkgs.mullvad-vpn`
3. **Move AWS Session Manager** from apt `.deb` to `pkgs.ssm-session-manager-plugin`
4. **Move Vagrant** from apt `.deb` to `pkgs.vagrant`
5. **Move fonts** from apt to nixpkgs equivalents
6. **Move desktop utils** (`arandr`, `blueman`, `maim`) from apt to nixpkgs

### Ruby/Python moved to nixpkgs

`ruby` and `python` moved from asdf to nixpkgs. This eliminates ~15 `lib*-dev` build dependency packages from apt.

### System-level packages that must stay in apt

| Package | Reason |
|---------|--------|
| `openssh-server` | Daemon |
| `laptop-mode-tools` | Not in nixpkgs |
| `virtualbox` | Needs kernel modules |
| `bridge-utils` | Network (usually root) |
| `hplip-gui` | Printer system integration |
| `policykit-1-gnome` | System auth agent |
| `duo-desktop` | Not in nixpkgs |
