# kitty-setup

My terminal look: **kitty** + **Catppuccin Mocha** + **JetBrainsMono Nerd Font** + a powerline **starship** prompt.

## Install on a new machine

```bash
git clone https://github.com/ysonggit/kitty-setup.git ~/kitty-setup
~/kitty-setup/install.sh
```

The script is idempotent. It:

- installs kitty to `~/.local/kitty.app` (official installer) and adds a desktop entry on Linux
- installs JetBrainsMono Nerd Font (`~/.local/share/fonts` or `~/Library/Fonts`)
- installs starship to `~/.local/bin`
- **symlinks** `kitty/kitty.conf` → `~/.config/kitty/kitty.conf` and `starship/starship.toml` → `~/.config/starship.toml` (existing files are backed up as `*.bak.<timestamp>`)
- appends `eval "$(starship init …)"` to `~/.bashrc` / `~/.zshrc` if missing

Only want the configs linked (tools already installed)? `./install.sh --no-install`

Because the configs are symlinks, edit them in place and `git commit` — other machines pick changes up with `git pull`.

## Highlights

| | |
|---|---|
| Theme | Catppuccin Mocha, 94% opacity, 12px padding, normal title bar |
| Cursor | beam with cursor trail |
| Tabs | top, powerline slanted |
| `ctrl+shift+enter` | new split in current dir |
| `ctrl+shift+t` | new tab in current dir |
| `ctrl+shift+z` | zoom current split (toggle stack layout) |
| Mouse | copy on select |
| Prompt | OS · user · dir · git · language · conda · time, then `❯` |
