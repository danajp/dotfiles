set -eo pipefail
[[ -n "$DEBUG" ]] && set -x

set_emacs() {
  local value="$1"
  emacsclient -e "(color-theme-sanityinc-solarized-${value})" >/dev/null 2>&1 || true
}

set_system_color_scheme() {
  local value="$1"
  if [[ "$value" == dark ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
  fi
}

target="$1"
case "$target" in
  dark | light) ;;
  *) echo "Usage: toggle-colors <dark|light>"; exit 1 ;;
esac

set_system_color_scheme "$target"
set_emacs "$target"
