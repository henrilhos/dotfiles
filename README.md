# dotfiles

Personal machine configuration for macOS. This branch tracks one specific setup: fish shell, Neovim (LazyVim), tmux, Ghostty, and the Homebrew packages that go with them. Other branches (`main`, `arco-linux`, `regolith`) cover different machines and operating systems and share no history with this one, so do not expect a clean merge between them.

## Layout

- `bootstrap.sh` runs the whole setup on a fresh machine.
- `scripts/setup/` holds one script per concern (git, Homebrew, dotfiles, macOS security, FileVault, Xcode CLT).
- `scripts/lib/` has the shared helpers those scripts source (logging, colors, sudo prompts, validation).
- `dotfiles/` mirrors `$HOME`. `dotfiles/.config/fish/config.fish` on disk ends up at `~/.config/fish/config.fish`, and so on.

## Running bootstrap

```sh
GIT_EMAIL="you@example.com" GIT_NAME="Your Name" GITHUB_USER="username" \
  /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/henrilhos/dotfiles/macos/bootstrap.sh)"
```

`GIT_NAME` and `GIT_EMAIL` are required, everything else has a default:

| Variable             | Default                                     | Purpose                                                              |
| -------------------- | ------------------------------------------- | -------------------------------------------------------------------- |
| `GIT_NAME`           | none, required                              | Git commit author name                                               |
| `GIT_EMAIL`          | none, required                              | Git commit author email                                              |
| `GIT_USERNAME`       | `henrilhos`                                 | GitHub username, also used to build `DOTFILES_URL`                   |
| `DOTFILES_URL`       | `https://github.com/$GIT_USERNAME/dotfiles` | Where to clone this repo from                                        |
| `DOTFILES_BRANCH`    | `main`                                      | Branch to check out, set to `macos` for this one                     |
| `STRAP_GITHUB_TOKEN` | unset                                       | If set, stores GitHub HTTPS credentials via `git credential approve` |
| `STRAP_ADMIN`        | detected from group membership              | Gates the macOS security and FileVault steps                         |

The script is idempotent. Re-running it after editing a dotfile just relinks and reinstalls what changed.

Admin-only steps (security defaults, FileVault) run only when the account is in the `admin` group and `STRAP_CI` is unset, so a CI run or a non-admin account skips them automatically instead of failing.

## How the symlinks work

`scripts/symlink.sh` walks `dotfiles/` one level deep. It links top-level files (`.gitconfig`, `.Brewfile`) straight to `$HOME`, and for top-level directories (`.config`, `.ssh`, `.gnupg`) it links their immediate children individually, so `dotfiles/.config/nvim` becomes one symlink at `~/.config/nvim`, not a tree of per-file links.

In practice, on this machine none of that ran. The files under `dotfiles/` are plain copies kept in sync by hand (or by Claude, when asked). If you bootstrap a brand new Mac from this branch the symlinks will actually get created; on a machine that already existed before this repo did, expect to reconcile drift occasionally with a diff against `$HOME`.

## Homebrew

`.Brewfile` lists taps, formulae, casks, VS Code extensions, and the odd global npm package. `scripts/setup/homebrew.sh` prefers `$HOME/.Brewfile` if one exists and falls back to the copy inside the repo, which is what actually happens here.

To regenerate it after installing or removing something:

```sh
brew bundle dump --file=dotfiles/.Brewfile --describe --force
```

PHP's dependency chain (`libpng`, `krb5`, `libxml2`, `openssl@3`, and a handful of others) shows up as "installed on request" in Homebrew's own bookkeeping, not just as a transitive dependency. `brew bundle dump` will happily list every one of those as a top-level formula. That is real, current state, not noise, so the Brewfile is longer than the "I use six tools" mental model suggests.

## Fish

`config.fish` sets `EDITOR`, `FZF_DEFAULT_COMMAND`, `ANDROID_HOME`, vi key bindings, and the pisces bracket-pairing config as universal variables on every launch. `~/.config/fish/fish_variables` is fish's own snapshot of that state plus fisher's plugin bookkeeping, and it is deliberately not tracked here. It bakes in the local username in absolute paths, so a copy taken on one Mac breaks quietly on another. `fish_plugins` is the real source of truth for which fisher plugins are installed; `fish_variables` regenerates itself the moment fish starts.

## Terminal and theme

Ghostty and tmux both point at a `dark2026` theme file (`dotfiles/.config/ghostty/themes/dark2026.conf` and `dotfiles/.config/tmux/dark2026_tmux.conf`). The active theme line in each config is the one without a `#` in front of it, the commented-out lines below it are past themes kept around in case I want to switch back.

## Neovim

LazyVim-based config under `dotfiles/.config/nvim`. `lazy-lock.json` pins exact plugin commits, update it with `:Lazy update` or `:Lazy sync` inside Neovim rather than editing it by hand.

## SSH and GPG

`.ssh/config` includes `~/.colima/ssh_config` and `~/.orbstack/ssh/config` unconditionally. Neither `Include` errors when the target file is missing, ssh just skips it, so the same config works whether this particular machine uses Colima, OrbStack, both, or neither. Git commit signing goes through 1Password's SSH agent (`gpg.format = ssh` in `.gitconfig`, `allowedsignersfile` pointing at `.ssh/allowed_signers`). GPG itself is only there for the odd thing that still wants a real PGP key.

## What is not synced

`.gitconfig`'s `user.email` intentionally stays a personal address rather than whatever work email happens to be set locally on a given machine. This repo is public, and a work address does not belong in it. Check `git config --global user.email` on the machine if something looks off.
