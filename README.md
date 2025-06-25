# Dotfiles

My personal dotfiles based on [br3ndonland](https://github.com/br3ndonland)

- [Overview](#overview)
  - [What](#what)
  - [Why](#why)
  - [How](#how)
- [macOS](#macos)
- [Homebrew package management](#homebrew-package-management)
- [Git](#git)
- [Shell](#shell)
- [Text editors](#text-editors)
  - [VSCode desktop](#vscode-desktop)
- [Fonts](#fonts)
- [Language-specific setup](#language-specific-setup)
  - [JavaScript](#javascript)
  - [Python](#python)
- [SSH](#ssh)
  - [Key generation](#key-generation)
  - [Connecting to GitHub](#connecting-to-github)
  - [SSH agent forwarding](#ssh-agent-forwarding)
  - [1Password SSH features](#1password-ssh-features)

## Overview

### What

This repo contains dotfiles, which are application configuration and settings files. They frequently begin with a dot, hence the name. Dotfiles are compatible with Linux and macOS.

### Why

- **Make developer environments automated and disposable**. [Disposability](https://12factor.net/disposability) is an important concept in [infrastructure-as-code DevOps](https://opentofu.org/docs/intro/use-cases/), [serverless computing](https://www.cloudflare.com/learning/serverless/what-is-serverless/), [CI/CD](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions), and more recently, [in-browser development environments](https://docs.github.com/en/codespaces/overview). Why aren't developers applying automation and disposability to their own computers? With an automated disposable developer environment, setup of a new machine is fast and easy. This approach is also liberating - I can purchase a new computer (or wipe an existing one), run _bootstrap.sh_, and be up and running again in no time.
- **Know when and why settings change**. I not only know what tools and settings I'm using, but when and why I chose the tools and settings. This has been particularly important for VSCode, because settings change (and [break](https://github.com/microsoft/vscode/labels/bug)) frequently, and it helps to record troubleshooting info in the Git log.
- **Learn new skills**. I learn skills, like shell scripting, that are useful and don't go out of date quickly. I wouldn't know shell as well if I didn't work on my developer environment. I learn these skills by tinkering a little bit at a time, in an unstructured way. It's time I might not otherwise be writing code.

### How

This dotfiles repository is meant to be installed by _[bootstrap.sh](bootstrap.sh)_.

_bootstrap.sh_ is a shell script to automate setup of a new macOS or Linux development machine. It is _idempotent_, meaning it can be run repeatedly on the same system. To set up a new machine, simply open a terminal and run the following command:

```sh
GIT_EMAIL="you@example.com" GIT_NAME="Your Name" GITHUB_USER="username" \
  /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/henrilhos/dotfiles/HEAD/bootstrap.sh)"
```

The following environment variables can be used to configure _bootstrap.sh_, and should be either set before with [`export`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#export), or inline within the command to run the script:

- `GIT_EMAIL`: email address to use for Git configuration. Will error and exit if not set.
- `GIT_NAME`: name to use for Git configuration. Will error and exit if not set.
- `GITHUB_USERNAME`: username on GitHub or other remote from which dotfiles repo will be cloned. Defaults to my GitHub username, so you should set this if you're not me.
- `STRAP_DOTFILES_URL`: URL from which the dotfiles repo will be cloned. Defaults to `https://github.com/$GITHUB_USER/dotfiles`, but any [Git-compatible URL](https://www.git-scm.com/docs/git-clone#_git_urls) can be used, so long as it is accessible at the time the script runs.
- `DOTFILES_BRANCH`: Git branch to check out after cloning dotfiles repo. Defaults to `main`.

There are some additional variables for advanced usage. Consult the _[bootstrap.sh](bootstrap.sh)_ script to see all supported variables.

_bootstrap.sh_ will set up macOS and Homebrew, run scripts in the _scripts/_ directory, and install Homebrew packages and casks from the _[Brewfile](Brewfile)_. A Brewfile is a list of [Homebrew](https://brew.sh/) packages and casks (applications) that can be installed in a batch by [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle). The Brewfile can even be used to install Mac App Store apps with the `mas` CLI. Note that you must sign in to the App Store ahead of time for `mas` to work.

The following list is a brief summary of permissions related to _bootstrap.sh_.

- Initial setup of Homebrew itself does not require an admin user account, but does require `sudo`. See the [Homebrew installation docs](https://docs.brew.sh/Installation), [Homebrew/install#312](https://github.com/Homebrew/install/issues/312), and [Homebrew/install#315](https://github.com/Homebrew/install/pull/315/files).
- [After Homebrew setup, use of `sudo` with `brew` commands is discouraged](https://docs.brew.sh/FAQ#why-does-homebrew-say-sudo-is-bad).
- After Homebrew setup, commands such as `brew bundle install --global` should be run from the same user account used for setup. Attempts to run `brew` commands from another user account will result in errors, because directories that need to be updated are owned by the setup account. If access to the setup account is not routinely available, an alternative approach could be to change ownership of Homebrew directories to a group that includes the user account used for Homebrew setup as well as other users that need to run Homebrew commands.
- _bootstrap.sh_ can run with limited functionality on non-admin and non-`sudo` user accounts. A plausible use case could exist in which an admin runs `bootstrap.sh` to configure the system initially, then a non-admin runs `bootstrap.sh` to configure their own account. In this use case, the non-admin user should not need admin or `sudo` privileges, because all the pertinent setup (FileVault disk encryption, XCode developer tools, Homebrew, etc) is already complete.

Users with more complex needs for multi-environment dotfiles management might consider a tool like [`chezmoi`](https://www.chezmoi.io/).

<!-- ## Hardware

- Apple Silicon [Macbook Pro]() -->

## macOS

- macOS setup is automated with _[macos.sh](scripts/macos.sh)_.
- [Karabiner Elements](https://karabiner-elements.pqrs.org/) is used for keymapping.

  - Settings are stored in _[.config/karabiner/karabiner.json](.config/karabiner/karabiner.json)_. Note that karabiner will auto-format the JSON with four spaces. To avoid changing the formatting with the [Prettier](https://prettier.io/) autoformatter, I added _karabiner.json_ to _.prettierignore_.
  <!-- TODO: atualizar com o que realmente foi modificado -->
  - Simple modifications:

    | From key  | To key    |
    | --------- | --------- |
    | caps_lock | escape    |
    | escape    | caps_lock |

  - Complex modifications:
    - Launch Terminal with Cmd+Escape
    - See _karabiner.json_ for more.
  - Devices
    - Disable built-in keyboard when external keyboard is connected

## Homebrew package management

- [Homebrew](https://brew.sh/) is a package manager that includes [Homebrew-Cask](https://github.com/homebrew/homebrew-cask) to manage other macOS applications. See the Homebrew [docs](https://docs.brew.sh) for further info.
- The list of "formulae" (packages), "casks" (apps), and `mas` apps (Mac App Store apps) is stored in _[Brewfile](Brewfile)_. The Brewfile works with [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) to manage all Homebrew packages and casks together.
- Key Brew Bundle commands:

  ```sh
  # Install of update everything in the Brewfile
  brew bundle install --global
  # Check for programs listed in Brewfile
  brew bundle check --global
  # Remove any Homebrew packages and casks not in Brewfile
  brew bundle cleanup --force --global
  # Show cache dir: https://docs.brew.sh/FAQ#where-does-stuff-get-downloaded
  brew --cache
  ```

## Git

- [Git](https://www.git-scm.com/) is the version control system used on GitHub. _[Why use Git?](https://www.git-scm.com/about)_ Git enables creation of multiple versions of a code repository called branches, with the ability to track and undo changes in detail. If you're new to Git, the [Git Book](https://www.git-scm.com/book/en/v2) is helpful.
- I install Git with Homebrew.
- I [configure Git to connect to GitHub with SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).
- I store Git configuration in _[.gitconfig](.gitconfig)_.
- I sign Git commits and tags with [1Password and SSH](#1password-ssh-features).
- _Why sign Git commits and tags?_
  - **Signing verifies user identity**. In case you haven't heard, [anyone can use Git to impersonate you](https://blog.1password.com/git-commit-signing/). Signing helps avoid impersonation attacks. The simplest form of signing can be seen when performing Git operations through the GitHub UI with valid credentials (making a commit, merging a PR, etc). As the [GitHub docs](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) explain, these operations are signed with GitHub's key (signature `4AEE18F83AFDEB23`). Operations signed with this key indicate valid GitHub credentials, so signing with GitHub's key is somewhat like one-factor authentication. To make this more secure, users can use their own keys, which involves generating and maintaining custody of a key, setting up Git to sign commits and tags with the key, and adding the public key to the GitHub account. This can be even more secure, somewhat like two-factor authentication, because it indicates that the user has both valid GitHub credentials and the valid private key used for signing. Signing with a user-generated key also allows attestation. If you navigate to [my GitHub profile](https://github.com/henrilhos), you can see several SSH and PGP key signatures that I have associated with my identity on GitHub. This means, "I attest that I possess the corresponding private keys and use them for signing." Commits and tags signed with those keys show up as "verified" on GitHub.
  - **Signing verifies changes**. This is especially important for tags because tags are often used to perform releases. Signed tags indicate that the release comes from a trusted source, because the user possessing the signing key has verified the contents of the release.
- See the [GitHub docs](https://docs.github.com/en/authentication/managing-commit-signature-verification) for further info on signing.

## Shell

- I use Zsh as my shell, which functions like Bash but offers more customization.
- I install with Homebrew to maintain consistent versions across multiple machines. However, note that [Zsh is now the default shell for new macOS users starting with macOS Catalina](https://support.apple.com/en-us/HT208050).
- See the [Wes Bos Command Line Power User course](https://commandlinepoweruser.com/) for an introduction to Zsh.
- I use [Starship](https://starship.rs/) for my shell prompt.
<!-- TODO: trocar para o Ghostty -->
- For my terminal application, I use [kitty](https://github.com/kovidgoyal/kitty), a GPU-based terminal emulator.

## Text editors

### VSCode desktop

I write code with [Microsoft Visual Studio Code](https://code.visualstudio.com/) (VSCode).

VSCode settings, keybindings, and extension lists are stored in this repo. Extensions can be installed by running _[vscode-extensions.sh](scripts/vscode-extensions.sh)_ along with the editor command name, like `vscode-extensions.sh code` for VSCodium. The script uses the [VSCode extension CLI](https://code.visualstudio.com/docs/editor/extension-gallery).

VSCode offers other options for managing settings. The [`Shan.code-settings-sync`](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) extension was popular in the past, and stored settings in a GitHub Gist. [VSCode now offers a built-in settings sync feature](https://code.visualstudio.com/docs/editor/settings-sync) ([introduced in VSCode 1.48 July 2020](https://code.visualstudio.com/updates/v1_48)). This repo uses Git for settings sync instead of VSCode's settings sync feature. _Why not use VSCode settings sync?_

- VSCode settings sync requires a Microsoft or GitHub login. What if you use GitLab?
- Where does VSCode settings sync actually store the data? The `Shan.code-settings-sync` extension stored data in a GitHub Gist, so it was possible to view the synced settings directly. VSCode only allows the synced settings to be viewed from within VSCode. There's no Git repo or Gist where you can go to see line-by-line changes.
- VSCode settings sync uses a "Merge or Replace" dialog box and a pseudo-Git merge conflict resolver. It can be complicated and confusing to use.

[VSCode profiles](https://code.visualstudio.com/docs/editor/profiles) ([introduced in VSCode 1.76 February 2023](https://code.visualstudio.com/updates/v1_76)) assist with switching among different editor environments, like personal and work computers. This repo does not use VSCode profiles, but uses a simple Git branching strategy for managing these environments. _Why not use VSCode profiles?_

- Most settings are the same across all profiles, but VSCode profiles store separate JSON settings for every profile
- Exporting a profile to a file exports the settings as an inline dumped JSON string, making version control and reading difficult
- Exporting a profile to a file includes metadata like `snippets.usageTimestamps`, which is apparently tracking every time snippets are used. Why? Why would you need to track this in a profile? This also makes version control more difficult because it creates a Git diff every time a snippet is used.
- The [VSCode profiles docs describe the use case](https://code.visualstudio.com/docs/editor/profiles#_uses-for-profiles) as, "Since profiles are remembered per workspace, they are a great way to customize VS Code for a specific programming language... Using this approach, you can easily switch between workspaces and always have VS Code configured the right way." There are already workspace and repo settings available that do the same thing.

<!-- TODO: adicionar neovim -->

## Fonts

I use [Recursive Mono](https://www.recursive.design/). It's available for download [from Homebrew](https://formulae.brew.sh/cask/font-recursive-code) (`brew install --cask font-recursive-code`) or [GitHub](https://github.com/arrowtype/recursive). [Fira Code](https://github.com/tonsky/FiraCode) and [Ubuntu Mono](https://design.ubuntu.com/font/) are decent free alternatives.

## Language-specific setup

### JavaScript

- [node](https://nodejs.org/en/) is a JavaScript runtime used to run JavaScript outside of a web browser.
- [npm](https://www.npmjs.com/) is a package manager written in node.js, included when node is installed.
  - It's difficult to keep track of global npm packages. There's no easy way to do it with the usual _package.json_. As Isaac Schlueter [commented](https://github.com/npm/npm/issues/2949#issuecomment-11408461) in 2012,
    > Yeah, we're never going to do this.
  - Instead, packages can be installed with Homebrew, or with _[npm-globals.sh](scripts/npm-globals.sh)_.
  - [npm-check](https://www.npmjs.com/package/npm-check) can be used to manage global packages after install, with `npm-check -ug`. If not using npm-check, a list of global npm packages can be seen after installation with `npm list -g --depth=0`.
- I use the [Prettier](https://prettier.io/) autoformatter and the [Prettier VSCode extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) to format my web code, including JavaScript and Vue.js. Prettier is an extremely helpful productivity tool, and I highly recommend it. Autoformatters save time and prevent [bikeshedding](https://www.freebsd.org/doc/en/books/faq/misc.html#idp50244984).
- Compared with Prettier, ESLint formats less code languages, requires complicated setup, and doesn't work well when installed globally.
- In the past, I also used [JavaScript Standard Style](https://standardjs.com/) (aka StandardJS). Standard Style has also [reportedly](https://changelog.com/podcast/359) been favored by Brendan Eich (creator of JavaScript) and Sir Tim Berners-Lee (creator of the World Wide Web). Prettier provides a similar code style, but with more features, so I use Prettier instead.

### Python

- I lint and format Python code with [Ruff](https://docs.astral.sh/ruff/).
  - The [Ruff VSCode extension](https://open-vsx.org/extension/charliermarsh/ruff) provides support for Ruff in VSCode. I set VSCode to autoformat on save.
  - Ruff is available as a [Homebrew formula](https://formulae.brew.sh/formula/ruff).
- See my [template-python](https://github.com/br3ndonland/template-python) repo for useful tooling and additional sensible defaults.

## SSH

### Key generation

To [generate an SSH key](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent):

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519_"$(id -un)"
```

If you have a FIDO2 security key that supports discoverable credentials (formerly known as resident keys), such as a YubiKey, you can [generate an SSH key that is stored directly on the FIDO2 hardware device](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key-for-a-hardware-security-key).

You'll need `libfido2` and OpenSSH version 8.2 or later.

```sh
brew install libfido2 openssh
```

Next, generate a key with the `-O resident` option. You can additionally set a PIN on the YubiKey, which requires the YubiKey Manager [CLI](https://developers.yubico.com/yubikey-manager/) or [GUI](https://www.yubico.com/support/download/yubikey-manager/), and require PIN verification for use of the SSH key, with the `-O verify-required` option. In this scenario, the SSH key itself does not need a password. The password is replaced by the YubiKey and its PIN.

```sh
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "your_email@example.com" -f ~/.ssh/id_ed25519_"$(id -un)"
```

### Connecting to GitHub

See the [GitHub docs on connecting to GitHub with SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

- [Add SSH key to GitHub account](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account):
  - Use the [GitHub CLI](https://cli.github.com/manual/gh_ssh-key_add): `gh ssh-key add`
  - Or, run `pbcopy < ~/.ssh/id_ed25519_"$(id -un)".pub`, and go to GitHub in a web browser and paste the key.
- [Check SSH connection](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/testing-your-ssh-connection) with `ssh -T git@github.com`.

GitHub supports use of SSH keys from FIDO2 security key hardware devices like YubiKeys. See the [GitHub docs](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key-for-a-hardware-security-key), [GitHub blog](https://github.blog/2021-05-10-security-keys-supported-ssh-git-operations/), and [Yubico blog](https://www.yubico.com/blog/github-now-supports-ssh-security-keys/).

GitHub also supports use of SSH keys for signing Git commits. See the [GitHub changelog](https://github.blog/changelog/2022-08-23-ssh-commit-verification-now-supported/) and [GitHub docs](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification). See the [1Password section](#1password-ssh-features) for instructions.

### SSH agent forwarding

If working on a server, you can use [ssh agent forwarding](https://docs.github.com/en/free-pro-team@latest/developers/overview/using-ssh-agent-forwarding) to access your SSH and GPG keys without having to copy them.

```text
Host yourserver.com
  ForwardAgent yes
```

### 1Password SSH features

[1Password includes features for managing SSH keys](https://developer.1password.com/docs/ssh). At this time, SSH features are limited to your Personal vault.

To [get started](https://developer.1password.com/docs/ssh/get-started):

- Generate or import an SSH key
- Upload the key to GitHub or any platform to which you connect with SSH
- Turn on the 1Password SSH agent
- Update the [SSH config](https://www.ssh.com/academy/ssh/config) to use the 1Password `IdentityAgent`
- Optionally, simplify the agent path by creating a symlink to `~/.1password/agent.sock`.

1Password also supports Git commit signing with SSH keys. See the [1Password blog](https://blog.1password.com/git-commit-signing/) and [GitHub changelog](https://github.blog/changelog/2022-08-23-ssh-commit-verification-now-supported/).

To [sign Git commits with SSH and 1Password](https://developer.1password.com/docs/ssh/git-commit-signing):

- [Tell GitHub about the SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account):
  - Go to https://github.com/settings/keys
  - Click "New SSH key"
  - Select the key type "signing key"
  - Allow the 1Password browser extension to autofill the "key" input field with an SSH public key. Either generate a new SSH key with 1Password or use an existing one. The same SSH key can be used for both authentication and signing.
- [Tell Git about the SSH key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-ssh-key):
  - Set `git config gpg.format = ssh`
  - Set `git config gpg.ssh.allowedsignersfile=~/.ssh/allowed_signers`
  - Set `git config gpg.ssh.program=/Applications/1Password.app/Contents/MacOS/op-ssh-sign`
  - Set `git config user.signingkey` to the SSH public key
  - Create the file `~/.ssh/allowed_signers` (when using this repo, will be symlinked from `~/.dotfiles/.ssh/allowed_signers`)
  - For each signing key, add a single line to the `~/.ssh/allowed_signers` specifying the combination of `git config user.email` and `git config user.signingkey`, in that order

<!-- TODO: atualizar com os meus apps -->
<!-- ## General productivity

- [1Password](https://1password.com/) (Mac App Store)
- [Backblaze](https://www.backblaze.com/) (Homebrew Cask or direct download)
- [Bear](https://bear.app) (Mac App Store)
- [Brave](https://brave.com/)
  - Brave profiles for each context (personal/work, different AWS accounts, etc)
  - [Brave sync](https://support.brave.com/hc/en-us/articles/360059793111-Understanding-Brave-Sync)
  - 1Password extension for desktop app
  - [DuckDuckGo Privacy Essentials](https://github.com/duckduckgo/duckduckgo-privacy-extension)
  - [SimpleLogin](https://simplelogin.io/) email alias generator ([SimpleLogin joined Proton](https://proton.me/blog/proton-and-simplelogin-join-forces) and now offers [sign in with Proton](https://proton.me/support/create-simplelogin-account-proton-account))
  - [Vue.js DevTools](https://github.com/vuejs/vue-devtools)
  - [Dark Reader](https://darkreader.org)
  - [Stylus](https://github.com/openstyles/stylus)
    - [Wide GitHub](https://github.com/xthexder/wide-github)
    - [GitHub Custom Fonts](https://github.com/StylishThemes/GitHub-Dark)
    - ~~[GitHub Dark](https://github.com/StylishThemes/GitHub-Dark)~~ _(GitHub [finally](https://github.blog/2020-12-08-new-from-universe-2020-dark-mode-github-sponsors-for-companies-and-more/) has a native dark mode!)_
    - [GitLab Dark](https://gitlab.com/maxigaz/gitlab-dark)
    - [Wikipedia Dark](https://github.com/n0x-styles/wikipedia-dark)
- macOS Keynote, Numbers, and Pages
- [Proton VPN](https://protonvpn.com/) (Homebrew Cask or direct download)

## Media

- [Audacity](https://www.audacityteam.org/)
- [HandBrake](https://handbrake.fr/)
- [Plex](https://www.plex.tv/) media server
- [VLC](https://www.videolan.org/vlc/) media player

## Science

- [Zotero](https://www.zotero.org/) -->

[(Back to top)](#top)
