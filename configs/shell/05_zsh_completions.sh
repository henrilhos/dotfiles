# 05_zsh_completions.sh - Initialize Zsh completion system
# This needs to run early in the startup process

if [[ -n "$ZSH_VERSION" ]]; then
    # -- Initialize Zsh's completion system with optimization
    # https://stevenvanbael.com/profiling-zsh-startup
    # https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
    # https://gist.github.com/ctechols/ca1035271ad134841284?permalink_comment_id=3994613
    autoload -Uz compinit
    for dump in ~/.zcompdump(N.mh+24); do
        compinit
    done
    compinit -C

    # Initialize Bash compatibility for completions
    autoload -U +X bashcompinit && bashcompinit

    zstyle ':completion:*' menu select
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
fi
