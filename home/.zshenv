export EDITOR="/usr/bin/nvim"
export VISUAL="/usr/bin/nvim"

# NVM
source /usr/share/nvm/init-nvm.sh

# PyEnv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Bin
if [ -d "$HOME/.bin" ]; then
    PATH="$HOME/.bin:$PATH"
fi

# Brew
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
