# 1Password CLI (`op`)

Reference notes for using `op` day to day. Not linked anywhere by dotbot —
just documentation to consult later.

## One-time setup

Already installed via `configs/nix-darwin/homebrew.nix` (`1password-cli`
cask). One manual step, since it's an app-internal toggle with no CLI/
nix-darwin equivalent:

**1Password app → Settings → Developer → "Integrate with 1Password CLI"**

With this on, `op` authenticates via Touch ID through the desktop app —
no `op signin` / master password needed for normal use.

## Core concept: `op://` references

Every secret is addressed as `op://<vault>/<item>/<field>`, e.g.:

```
op://Private/API-Key/credential
op://Work/Database/password
```

These references are safe to commit — they're just pointers, not secrets.

## Commands

```sh
op whoami                              # confirm you're authenticated
op vault list                          # list vaults
op item list                           # list items in a vault
op item get "API Key" --vault Private  # view an item
op read "op://Private/API-Key/credential"   # print a single field's value
```

## Pattern 1: `op run` — inject secrets as env vars, nothing touches disk

`.env` (safe to commit — no real secrets, just references):

```sh
API_KEY="op://Private/API-Key/credential"
DATABASE_URL="op://Work/Database/connection-string"
```

Run any command with those resolved into its environment:

```sh
op run --env-file=.env -- npm start
op run --env-file=.env -- python manage.py runserver
```

The secrets exist only in the child process's memory — never written to
disk, never in shell history.

## Pattern 2: `op inject` — templated config files

For tools that need an actual file (not env vars), template it:

`config.yaml.tpl`:

```yaml
api_key: op://Private/API-Key/credential
```

```sh
op inject -i config.yaml.tpl -o config.yaml
```

`config.yaml.tpl` is safe to commit; the generated `config.yaml` is not
(add it to `.gitignore`).

## Pattern 3: combine with `direnv`

Since `direnv` is already set up (`configs/zsh/aliases.zsh`), a project's
`.envrc` can shell out to `op` so secrets load automatically on `cd`:

```sh
# .envrc
export API_KEY="$(op read op://Private/API-Key/credential)"
```

(Each `op read` call re-authenticates via the desktop app if needed — for
many variables, `op run --env-file=.env -- direnv exec . $SHELL` or just a
plain `op run` wrapper avoids one `op` call per variable.)

## Note on git/SSH

The SSH agent and commit signing set up in `configs/ssh/config` and
`configs/git/gitconfig` already go through 1Password — `op` is the same
underlying vault, just a CLI for everything else.
