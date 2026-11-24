#!/usr/bin/env bash
# Install kitty + JetBrainsMono Nerd Font + starship, and link the configs in this repo.
# Safe to re-run. Linux and macOS. Usage: ./install.sh [--no-install]  (only link configs)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
BIN="$HOME/.local/bin"
mkdir -p "$BIN" "$HOME/.config/kitty"

say() { printf '\033[1;35m==>\033[0m %s\n' "$*"; }

link() {  # link SRC DEST, backing up an existing real file
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    say "backed up existing $dest"
  fi
  ln -sfn "$src" "$dest"
  say "linked $dest -> $src"
}

if [ "${1:-}" != "--no-install" ]; then
  # ── kitty ──────────────────────────────────────────
  if ! command -v kitty >/dev/null 2>&1 && [ ! -x "$HOME/.local/kitty.app/bin/kitty" ]; then
    say "installing kitty"
    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
  fi
  if [ "$OS" = Linux ] && [ -d "$HOME/.local/kitty.app" ]; then
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/kitty.app/bin/kitten" "$BIN/"
    mkdir -p "$HOME/.local/share/applications"
    cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"
    sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g; s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" \
      "$HOME/.local/share/applications/kitty"*.desktop
  fi

  # ── JetBrainsMono Nerd Font ────────────────────────
  if [ "$OS" = Darwin ]; then FONT_DIR="$HOME/Library/Fonts"; else FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"; fi
  if ! ls "$FONT_DIR"/JetBrainsMonoNerdFont-Regular.ttf >/dev/null 2>&1; then
    say "installing JetBrainsMono Nerd Font"
    mkdir -p "$FONT_DIR"
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/f.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    tar -xJf "$tmp/f.tar.xz" -C "$tmp"
    cp "$tmp"/JetBrainsMonoNerdFont-*.ttf "$FONT_DIR/"
    rm -rf "$tmp"
    command -v fc-cache >/dev/null && fc-cache -f "$FONT_DIR" >/dev/null
  fi

  # ── starship ───────────────────────────────────────
  if ! command -v starship >/dev/null 2>&1 && [ ! -x "$BIN/starship" ]; then
    say "installing starship"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$BIN"
  fi
fi

# ── configs ──────────────────────────────────────────
link "$REPO/kitty/kitty.conf"        "$HOME/.config/kitty/kitty.conf"
link "$REPO/starship/starship.toml"  "$HOME/.config/starship.toml"

# ── shell hook ───────────────────────────────────────
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || continue
  shell="$(basename "$rc" | sed 's/^\.\(.*\)rc$/\1/')"
  grep -q 'starship init' "$rc" || {
    printf '\n# Starship prompt\nexport PATH="$HOME/.local/bin:$PATH"\neval "$(starship init %s)"\n' "$shell" >> "$rc"
    say "added starship to $rc"
  }
done

say "done — open a new kitty window (ctrl+shift+F5 reloads config in a running one)"
