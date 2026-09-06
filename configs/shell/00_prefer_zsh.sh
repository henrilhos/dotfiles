# prefer_zsh.sh - meant to be sourced in .bash_profile/.bashrc

# Change to zsh only if it's interactive, from https://unix.stackexchange.com/a/26782
if [[ ($- == *i*) && -z "$ZSH_VERSION" ]]; then
  export SHELL=$(which zsh)
  if [[ ! -z "${SHELL// /}" ]]; then
    unset FPATH # https://github.com/TACC/Lmod/commit/b75b04b7c1a976cf20d633f2d1ca9b0cc6a9db87
    # Only if zsh is installed and we're not already in zsh
    exec "$SHELL" -l
  fi
fi
