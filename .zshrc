#!/usr/bin/env zsh
### Zsh configuration
# usage: ln -fns $(pwd)/.zshrc ~/.zshrc

### options
# initial setup configured by zsh-newuser-install
# To re-run setup: autoload -U zsh-newuser-install; zsh-newuser-install -f
# See man zshoptions or https://zsh.sourceforge.net/Doc/Release/Options.html
HISTFILE=~/.zsh_history
HISTSIZE=10000
setopt prompt_subst autocd extendedglob globdots histignorespace noautomenu nullglob

# autoload -Uz compinit
# compinit

### keybindings
bindkey '^w' autosuggest-execute
# bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
# bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
# bindkey '^I' autosuggest-accept

### homebrew
if [[ -z $HOMEBREW_PREFIX ]]; then
  case $(uname) in
  Darwin)
    if [[ $(uname -m) == 'arm64' ]]; then
      HOMEBREW_PREFIX='/opt/homebrew'
    elif [[ $(uname -m) == 'x86_64' ]]; then
      HOMEBREW_PREFIX='/usr/local'
    fi
    ;;
  Linux)
    if [[ -d '/home/linuxbrew/.linuxbrew' ]]; then
      HOMEBREW_PREFIX='/home/linuxbrew/.linuxbrew'
    elif [[ -d $HOME/.linuxbrew ]]; then
      HOMEBREW_PREFIX=$HOME/.linuxbrew
    fi
    if [[ -d $HOMEBREW_PREFIX ]]; then
      PATH=$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH
    fi
    ;;
  esac
fi
if [[ -d $HOMEBREW_PREFIX ]]; then
  eval $($HOMEBREW_PREFIX/bin/brew shellenv)
fi

### exports
if type nvim &>/dev/null; then
  editor='nvim'
elif type codium &>/dev/null; then
  editor='codium --wait'
elif type cursor &>/dev/null; then
  editor='cursor --wait'
elif type code &>/dev/null; then
  editor='code --wait'
elif type code-insiders &>/dev/null; then
  editor='code-insiders --wait'
elif type code-exploration &>/dev/null; then
  editor='code-exploration --wait'
else
  editor='vim'
fi

TTY=$(tty)
CURL_BIN_DIR=$HOMEBREW_PREFIX/opt/curl/bin
CURL_CPPFLAGS=-I$HOMEBREW_PREFIX/opt/curl/include
CURL_LDFLAGS=-L$HOMEBREW_PREFIX/opt/curl/lib
CURL_PKG_CONFIG_PATH=$HOMEBREW_PREFIX/opt/curl/lib/pkgconfig
GNU_AWK_BIN_DIR=$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin
GNU_COREUTILS_BIN_DIR=$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin
GNU_FINDUTILS_BIN_DIR=$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin
GNU_GREP_BIN_DIR=$HOMEBREW_PREFIX/opt/grep/libexec/gnubin
GNU_SED_BIN_DIR=$HOMEBREW_PREFIX/opt/gsed/libexec/gnubin
GNU_TAR_BIN_DIR=$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin
LOCAL_BIN_DIR=$HOME/.local/bin
RUST_CARGO_BIN_DIR=$HOME/.cargo/bin
path_array=(
  $CURL_BIN_DIR
  $GNU_AWK_BIN_DIR
  $GNU_COREUTILS_BIN_DIR
  $GNU_FINDUTILS_BIN_DIR
  $GNU_GREP_BIN_DIR
  $GNU_SED_BIN_DIR
  $GNU_TAR_BIN_DIR
  $LOCAL_BIN_DIR
  $RUST_CARGO_BIN_DIR
  $PATH
)
export \
  CPPFLAGS=$CURL_CPPFLAGS \
  EDITOR=$editor \
  GIT_EDITOR=$editor \
  GPG_TTY=$TTY \
  HOMEBREW_NO_ANALYTICS=1 \
  LDFLAGS=$CURL_LDFLAGS \
  PATH="$(
    IFS=:
    echo "${path_array[*]}"
  )" \
  PIPX_BIN_DIR=$LOCAL_BIN_DIR \
  PKG_CONFIG_PATH=$CURL_PKG_CONFIG_PATH

# You may need to manually set your language environment
export LANG=en_US.UTF-8
### aliases
alias python='python3'
alias tg='terragrunt'

alias la=tree
alias cat=bat
alias ls=eza
alias cd=z

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

alias cl='clear'

# eza
alias l="eza -l --git -a"
alias lt="eza --tree --level=2 --long --git"
alias ltree="eza --tree --level=2 --git"

# sail
alias sail='sh vendor/bin/sail'

### prompt: https://starship.rs
source <(starship init zsh)

### mise: https://mise.jdx.dev/
# source <(mise activate zsh)

### functions
# ensure .zfunc is symlinked to $HOME/.zfunc
typeset -U fpath
fpath+=($HOME/.zfunc)
autoload -Uz $HOME/.zfunc/*(:tX)

### completions
if type brew &>/dev/null && [[ -d $HOMEBREW_PREFIX ]]; then
  fpath+=($HOMEBREW_PREFIX/share/zsh/site-functions)
fi
zstyle :compinstall filename $HOME/.zshrc
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

### env variables
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

### java and android studio
. ~/.asdf/plugins/java/set-java-home.zsh
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

### bat as manpage
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

### syntax highlighting
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"
