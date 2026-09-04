# dotfiles

Personal macOS configuration, built with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager): fish, Neovim (LazyVim), tmux, Ghostty,
and the packages that go with them. `arco-linux` and `regolith` cover other machines and share no
history with this branch, so do not expect a clean merge between them.

The machine's state is a build artifact of this repo. `./rebuild.sh` reconciles `$HOME` and the
system with whatever the `.nix` files here say, and `sudo darwin-rebuild --rollback` undoes it.

## Layout

- `flake.nix` — inputs, pins, and the single `darwinConfigurations."Henriques-MacBook-Pro"` output.
- `modules/darwin/` — system-level: macOS defaults, fonts, Touch ID sudo, Homebrew.
- `modules/home/` — user-level, one file per tool. `default.nix` holds the package list and the
  imports; everything else configures one program.
- `modules/home/themes/` — colour palettes as data. `dark2026.nix` feeds both Ghostty and tmux;
  `catppuccin-mocha.nix` feeds fish.
- `config/` — the two things that are deliberately *not* generated. See below.
- `bootstrap.sh` — fresh machine, run once.
- `rebuild.sh` — everything after that.

## Migration in progress

`dotfiles/`, `scripts/` and `vscode/User/settings.json` are the old bash setup and are still here on
purpose: `$HOME` is currently symlinked into them, so deleting them before the first
`darwin-rebuild switch` breaks the live shell, git and editor config. `./bootstrap.sh` clears those
symlinks as part of the cutover. Delete the three once a switch has succeeded.

## Daily use

```sh
# edit any .nix file, then
./rebuild.sh
```

Before applying, it's worth building first — this touches nothing:

```sh
nix build '.#darwinConfigurations."Henriques-MacBook-Pro".system'
```

Updating pins:

```sh
nix flake update            # all inputs
nix flake update nixpkgs    # just one
```

`nr`, `nu` and `nq` are fish abbreviations for rebuild, update, and opening this repo in Neovim.

## Fresh machine

```sh
git clone https://github.com/henrilhos/dotfiles ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.sh
```

`bootstrap.sh` installs Nix if missing, moves the installer's `/etc/nix/nix.conf` aside so nix-darwin
can own it, backs up any pre-existing dotfiles it would otherwise refuse to overwrite, then runs the
first `darwin-rebuild switch` straight from the flake (`darwin-rebuild` doesn't exist yet at that
point).

Two things Nix can't do:

- grant Karabiner-Elements its input-monitoring permission
- sign in to 1Password and turn on its SSH agent, which git commit signing depends on

## What is generated and what is not

Almost everything is generated into the Nix store and symlinked read-only into place — editing
`~/.config/fish/config.fish` directly will not survive a rebuild, and there is no longer a copy of it
in this repo to edit. Change `modules/home/fish.nix` instead.

Two exceptions, both under `config/`, linked with `mkOutOfStoreSymlink` so they stay writable:

- `config/nvim/` — LazyVim writes `lazy-lock.json` and `lazyvim.json` in place. A store copy would
  break `:Lazy sync`. Update plugins from inside Neovim; the lockfile change lands back in this repo.
- `config/vscode/cspell.json` — the spell-checker extension appends to it when you pick "add word to
  dictionary".

## Packages

Nixpkgs owns the CLI. Homebrew is down to GUI casks plus three things nixpkgs can't provide on
`aarch64-darwin`, each for a checked reason:

| Item | Why it stays Homebrew |
| --- | --- |
| `ghostty` | nixpkgs' `ghostty` has no darwin build |
| `mole` | nixpkgs' `mole` is marked `meta.broken` |
| `j4c` | not packaged in nixpkgs |

Ghostty's *configuration* is still declarative (`modules/home/ghostty.nix`) — only the binary comes
from the cask.

`homebrew.onActivation.cleanup` is `"none"`, not `"zap"`. Zap uninstalls anything not listed in
`modules/darwin/homebrew.nix`, which is the right end state but not while packages are still moving
out of Homebrew. Flip it once the cask list is confirmed complete.

The old `.Brewfile` listed PHP's dependency chain (`libpng`, `freetype`, `gettext`, `icu4c`, `gd`,
`krb5`, `libzip`, `jpeg`, `libedit`, `libiconv`, `zlib`) as top-level formulae because
`brew bundle dump` promotes anything "installed on request". Those are gone: under Nix they are
closure dependencies of `php83` and never get named.

Two VS Code extensions — cspell's bundled-dictionaries and Portuguese-Brazilian packs — have no
nixpkgs attribute and stay marketplace installs. The other three are pinned in
`modules/home/vscode.nix`.

## Fish

`fisher` is gone. Plugins are pinned as flake inputs (`fzf-fish`, `pisces`) and installed by
home-manager, so the ~30 vendored function files that used to be committed here no longer exist.
`fishPlugins.fzf-fish` isn't used because nixpkgs marks it broken; the plugin source is taken
directly instead.

The Catppuccin Mocha colours are set as shell-local variables from
`modules/home/themes/catppuccin-mocha.nix` rather than through `fish_config theme choose`, which
writes into the untracked `fish_variables`.

`~/.config/fish/secrets.fish` is sourced if present and is deliberately never tracked.

## tmux

TPM is gone along with the 5.8 MB of vendored plugins. `programs.tmux.plugins` pulls them from
nixpkgs instead.

One ordering constraint survives the port and is worth knowing before editing
`modules/home/tmux.nix`: `status-right` has to be assigned *after* catppuccin loads (it defines the
`@catppuccin_status_*` variables) but *before* tmux-cpu and tmux-battery load, because those two work
by text-replacing their placeholders inside the current `status-right` value. home-manager emits each
plugin's `extraConfig` directly before that plugin's `run-shell`, and the module-level `extraConfig`
after the whole plugin block — so `status-right` is attached to the `cpu` entry. Moving it into
`extraConfig` silently breaks the CPU and battery modules.

## Signing

Commits are signed with SSH through 1Password's agent (`gpg.format = ssh`, `op-ssh-sign`), not GPG.
`~/.ssh/allowed_signers` is generated from `modules/home/git.nix`. GPG is configured
(`modules/home/gpg.nix`) only for the occasional thing that insists on a real PGP key.

`user.email` is deliberately the personal address, not whatever work email is set locally — this repo
is public.

## Rollback

```sh
sudo darwin-rebuild --rollback
```

Older generations are under `/nix/var/nix/profiles/`.
