# dotfiles

Personal macOS setup, built incrementally rather than copied wholesale from
somewhere else. Every tool in here was added because it's actually used, not
because it looked good in someone else's repo.

## Stack

- **[dotbot](https://github.com/anishathalye/dotbot)** — declarative symlink
  management, driven by [`install.conf.yaml`](install.conf.yaml).
- **zsh** — shell, with a small `command -v`-guarded
  [`aliases.zsh`](configs/zsh/aliases.zsh) instead of a heavier plugin
  manager.
- **[nix-darwin](https://github.com/LnL7/nix-darwin)** — declarative macOS
  system configuration (`configs/nix-darwin/`), including **Homebrew**
  managed through its `homebrew` module (`onActivation.cleanup = "zap"`, so
  `brews`/`casks` are the single source of truth for installed packages).
- **[LazyVim](https://www.lazyvim.org/)** — Neovim config (`configs/nvim/`),
  stock starter template plus a private
  [Dracula PRO](https://draculatheme.com/pro) colorscheme.
- **[Ghostty](https://ghostty.org/)** — terminal, themed with the same
  Dracula PRO palette.
- **[Karabiner-Elements](https://karabiner-elements.pqrs.org/)** — remaps
  Caps Lock into a Hyper key (⌘⌃⌥⇧, tap for Escape), fixes the British
  keyboard's backtick position, and launches a few apps.
- **[Rectangle](https://rectangleapp.com/)** — window snapping, also bound to
  the Hyper key.
- **1Password** — SSH agent (`configs/ssh/config`) and SSH-based commit
  signing (`configs/git/gitconfig`, `configs/git/allowed_signers`).

## Setup

On a fresh macOS machine:

```sh
DOTFILES_REPO=git@github.com:henrilhos/dotfiles.git \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henrilhos/dotfiles/main/scripts/bootstrap.sh)"
```

See [`scripts/bootstrap.sh`](scripts/bootstrap.sh) for what that actually
does: Xcode Command Line Tools, Homebrew, Nix (via the
[Determinate installer](https://determinate.systems/)), clone this repo,
run `./install`, then `darwin-rebuild switch`.

If the repo is already cloned, just run `./scripts/bootstrap.sh` directly —
every step checks whether it's already done first, so it's safe to re-run.

## Day to day

- `./install` — re-run dotbot after adding/changing a symlink in
  `install.conf.yaml`.
- `sudo darwin-rebuild switch` — apply any change under `configs/nix-darwin/`
  (Homebrew packages, macOS defaults, etc.).

## Note on the Dracula PRO submodule

`submodules/dracula-pro-ghostty` points at a private repo — Dracula PRO is a
paid product. Cloning this repo works fine without access to it; you'll just
be missing that one file `configs/ghostty/config` references via
`config-file`. No paid content is vendored into this repo itself.
