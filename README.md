# dotfiles

Our Apple Silicon macOS setup, built incrementally rather than copied
wholesale from somewhere else. Every tool in here was added because it's
actually used, not because it looked good in someone else's repo.

It's a template: fork or clone it, fill in the `CHANGEME`s (see
[First steps](#first-steps)), and make it yours. There's no expectation of
pulling updates back.

## Stack

- **[dotbot](https://github.com/anishathalye/dotbot)** — declarative symlink
  management, driven by [`install.conf.yaml`](install.conf.yaml).
- **zsh** — shell, with a small set of `command -v`-guarded aliases and
  Oh My Zsh plugins.
- **[nix-darwin](https://github.com/LnL7/nix-darwin)** — declarative macOS
  system configuration (`configs/nix-darwin/`), including **Homebrew**
  managed through its `homebrew` module (`onActivation.cleanup = "zap"`, so
  `brews`/`casks` are the single source of truth for installed packages).
- **[LazyVim](https://www.lazyvim.org/)** — Neovim config (`configs/nvim/`),
  stock starter template plus the
  [Ayu](https://github.com/Shatur/neovim-ayu) colorscheme, toggled to Ayu
  Light by
  [dark-notify](https://github.com/cormacrelf/dark-notify) when macOS
  switches Appearance.
- **[Ghostty](https://ghostty.org/)** — terminal, themed with the same
  Ayu / Ayu Light palettes, switching automatically with macOS
  Appearance via its native light/dark `theme` support.
- **[tmux](https://github.com/tmux/tmux)** — terminal multiplexer
  (`configs/tmux/`), status line themed the same way via
  [tmux-dark-notify](https://github.com/erikw/tmux-dark-notify) (installed
  through [TPM](https://github.com/tmux-plugins/tpm), which bootstraps
  itself on first run).
- **Ayu** — `bat` also follows macOS Appearance; `git-delta`, `lazygit`,
  `btop`, and `fzf` can't, so they stay on Ayu Dark.
- **[Karabiner-Elements](https://karabiner-elements.pqrs.org/)** — remaps
  Caps Lock into a Hyper key (⌘⌃⌥⇧, tap for Escape) and launches a few
  apps.
- **[Rectangle](https://rectangleapp.com/)** — window snapping, also bound to
  the Hyper key.
- **[Secretive](https://github.com/maxgoedjen/secretive)** — SSH agent
  (`configs/ssh/config`) with keys in the Secure Enclave. Commit signing is
  optional; see [`docs/secretive.md`](docs/secretive.md).

## First steps

Before the first run, in your fork:

- [ ] `configs/git/gitconfig` — `name` and `email`.
- [ ] `configs/git/work.gitconfig` — work `email`, used inside `~/Work/`.
- [ ] `configs/nix-darwin/flake.nix` — the `hosts` entry: key is
  `scutil --get LocalHostName`, `username` is `whoami`.
- [ ] `configs/nix-darwin/homebrew.nix` — trim `brews`/`casks` to what you
  use. **Careful:** `cleanup = "zap"` uninstalls every Homebrew package not
  listed there, app data included, on each `darwin-rebuild switch`.
- [ ] `configs/karabiner/karabiner.json` — the Hyper key app launchers
  point at specific apps.

## Setup

On a fresh macOS machine:

```sh
DOTFILES_REPO=https://github.com/<you>/dotfiles.git \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/scripts/bootstrap.sh)"
```

See [`scripts/bootstrap.sh`](scripts/bootstrap.sh) for what that actually
does: Xcode Command Line Tools, Homebrew, Nix (via the
[Determinate installer](https://determinate.systems/)), clone this repo,
run `./install`, then `darwin-rebuild switch`.

If the repo is already cloned, just run `./scripts/bootstrap.sh` directly —
every step checks whether it's already done first, so it's safe to re-run.

## Manual steps (no scriptable equivalent)

A few settings are app-internal toggles or plist domains too opaque to
manage declaratively — done once by hand on a fresh machine:

- **Input source** — System Settings → Keyboard → Input Sources → add
  *U.S. International*. (HIToolbox's input-source list has no stable
  scriptable format.)
- **Secretive** — create an SSH key (see
  [`docs/secretive.md`](docs/secretive.md)).
- **Karabiner-Elements** — after editing
  [`configs/karabiner/karabiner.json`](configs/karabiner/karabiner.json),
  run `./install` again (Karabiner rewrites the file in place on launch,
  which breaks the dotbot symlink) and fully quit/relaunch the app to pick
  up the change.

## Day to day

- `./install` — re-run dotbot after adding/changing a symlink in
  `install.conf.yaml`.
- `sudo darwin-rebuild switch` — apply any change under `configs/nix-darwin/`
  (Homebrew packages, macOS defaults, etc.).
