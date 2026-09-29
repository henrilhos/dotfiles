# Secretive

SSH keys for this setup live in [Secretive](https://github.com/maxgoedjen/secretive):
they're generated inside the Mac's Secure Enclave, can't be exported, and
every use asks for Touch ID. `configs/ssh/config` points every SSH
connection at Secretive's agent, and the cask is in
`configs/nix-darwin/homebrew.nix`.

We don't need SSH for GitHub itself: git talks to GitHub over HTTPS with
`gh` as the credential helper (`configs/git/gitconfig`). Secretive covers
SSH into servers and, optionally, commit signing.

## Trade-off

One key per machine, and it can't be backed up or copied. Lose or wipe
the Mac and the key is gone. That's fine for what it's used for here:
make a new key on the new machine and register it wherever the old one
was.

## Create a key

1. Open **Secretive** and click **+**. Name it after the machine (e.g.
   `work-mbp`) and leave **Require authentication** on.
2. Select the key and copy its public key (the `ecdsa-sha2-nistp256 ...`
   line). Secretive also writes it to
   `~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/`.
3. Check the agent sees it:

   ```sh
   ssh-add -l
   ```

## Register it on GitHub

GitHub → Settings → **SSH and GPG keys** → **New SSH key**, paste the
public key, and pick the type:

- **Authentication key**: only if you want SSH access to GitHub (e.g.
  `git@github.com:` remotes). HTTPS + `gh` doesn't need it.
- **Signing key**: needed for the next section. The same key can be added
  twice, once per type.

## Optional: sign commits

Signing is off by default. To turn it on, uncomment the signing block in
`configs/git/gitconfig` and paste your public key after `key::`:

```gitconfig
[user]
	signingkey = key::ecdsa-sha2-nistp256 AAAA...
[gpg]
	format = ssh
[commit]
	gpgsign = true
```

Each commit then asks for Touch ID. GitHub shows it as **Verified** once
the key is registered as a signing key.

To make `git log --show-signature` verify locally too, add an allowed
signers file:

```sh
echo "$(git config user.email) ecdsa-sha2-nistp256 AAAA..." > ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
```
