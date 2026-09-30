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
- **[Ghostty](https://ghostty.org/)** — terminal.
- **Ayu Dark** — the one theme across Ghostty, `bat`, `git-delta`, `btop`,
  and `fzf`.

## First steps

Before the first run, in your fork:

- [ ] `configs/git/gitconfig` — `name` and `email`.
- [ ] `configs/git/work.gitconfig` — work `email`, used inside `~/Work/`.
- [ ] `configs/nix-darwin/flake.nix` — the `hosts` entry: key is
  `scutil --get LocalHostName`, `username` is `whoami`.
- [ ] `configs/nix-darwin/homebrew.nix` — trim `brews`/`casks` to what you
  use. **Careful:** `cleanup = "zap"` uninstalls every Homebrew package not
  listed there, app data included, on each `darwin-rebuild switch`.

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

## Day to day

- `./install` — re-run dotbot after adding/changing a symlink in
  `install.conf.yaml`.
- `sudo darwin-rebuild switch` — apply any change under `configs/nix-darwin/`
  (Homebrew packages, macOS defaults, etc.).
