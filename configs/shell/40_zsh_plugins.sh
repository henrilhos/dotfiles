# zsh_plugins.sh - meant to be sourced in .zshrc

if [[ ($- == *i*) && -n "$ZSH_VERSION" ]]; then
    # -- History (oh-my-zsh's lib/history.zsh sets similar defaults, but only
    # if unset, and doesn't dedupe non-consecutive repeats or blank lines)
    HISTFILE=~/.zsh_history
    HISTSIZE=50000
    SAVEHIST=50000
    setopt EXTENDED_HISTORY      # save timestamp + duration
    setopt SHARE_HISTORY         # sync across sessions as commands run — key for tmux panes
    setopt HIST_IGNORE_ALL_DUPS  # dedupe across the whole file, not just consecutive runs
    setopt HIST_IGNORE_SPACE     # leading space = don't record (secrets, one-offs)
    setopt HIST_REDUCE_BLANKS
    setopt HIST_VERIFY           # expand !! etc. into the prompt instead of running immediately

    # -- completions (fpath before omz runs compinit)
    [[ -d ~/.zfunc ]] && fpath+=~/.zfunc

    # -- oh-my-zsh
    # (up/down arrow history search is bound by omz/lib/key-bindings.zsh, no need to redo it)
    DEFAULT_USER="henrilhos"
    export DISABLE_AUTO_UPDATE=true  # Speedup of 40%
    plugins=( git sudo docker-compose )
    command -v eza >/dev/null && zstyle ':omz:lib:directories' aliases no  # Skip aliases in directories.zsh if eza
    export ZSH=~/dotfiles/submodules/oh-my-zsh
    source $ZSH/oh-my-zsh.sh

    # -- Reassert tool preferences oh-my-zsh's own defaults just clobbered
    # (also defined in 10_aliases.sh for bash, but oh-my-zsh loads after it here)
    alias ll='eza -lah'
    alias ls='eza'
    alias lt='eza --tree'
    alias vim='nvim'
    alias lg='lazygit'
    alias cat='bat'

    # -- Prompt
    if command -v starship >/dev/null 2>&1; then
      eval "$(starship init zsh)"
    else
      PROMPT='%F{cyan}%~%f %# '
    fi

    # -- zoxide
    eval "$(zoxide init zsh --cmd cd)"

    # -- zoxide-aware cd: stay in the current git worktree when zoxide jumps
    # to a path that's actually another worktree of the same repo
    zwt() {
        local current_root target root rel rewritten
        local current_common root_common

        current_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
            cd "$@"
            return
        }

        target=$(zoxide query --exclude "$PWD" -- "$@") || return
        root=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null) || {
            cd "$target"
            return
        }

        current_common=$(git -C "$current_root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
            cd "$target"
            return
        }
        root_common=$(git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
            cd "$target"
            return
        }

        # If zoxide picked another worktree of the same repo, preserve the relative path.
        if [[ "$root_common" == "$current_common" ]]; then
            if [[ "$target" == "$root" ]]; then
                rewritten="$current_root"
            else
                rel=${target#$root/}
                rewritten="$current_root/$rel"
            fi
            [[ -d "$rewritten" ]] && cd "$rewritten" && return
        fi

        cd "$target"
    }

    # -- fzf
    eval "$(fzf --zsh)"
    # Dracula theme: https://github.com/dracula/fzf
    export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

    # -- direnv
    eval "$(direnv hook zsh)"

    # -- mise
    # --shims instead of the full activate hook: a one-time PATH prepend
    # instead of a precmd hook that re-runs `mise hook-env` on every prompt
    # (measured ~12ms/prompt) — worth it since config.toml only pins plain
    # runtime versions, no dynamic env vars to track.
    eval "$(mise activate zsh --shims)"

    # -- sesh
    # Alt-s opens sesh's fzf picker straight from zsh (outside tmux, connecting
    # just attaches to/creates the session — no need to already be in one).
    # https://github.com/joshmedeski/sesh#zsh-keybind
    function sesh-sessions() {
        {
            exec </dev/tty
            exec <&1
            local session
            session=$(sesh list --icons | fzf --ansi --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
            zle reset-prompt >/dev/null 2>&1 || true
            [[ -z "$session" ]] && return
            sesh connect "$session"
        }
    }
    zle -N sesh-sessions
    bindkey -M emacs '\es' sesh-sessions
    bindkey -M viins '\es' sesh-sessions

    # -- fix Atuin [Ctrl-r] key binding (after omz's key-bindings.zsh and fzf's own eval)
    eval "$(atuin init zsh)"
    bindkey -M emacs '^r' atuin-search

    # -- Custom keybindings (Alt/Option key combinations)
    # Based on oh-my-zsh dirhistory plugin escape sequences
    function _cd_up() { zle .kill-buffer; cd ..; zle .accept-line }
    function _cd_back() { zle .kill-buffer; cd - >/dev/null; zle .accept-line }
    zle -N _cd_up
    zle -N _cd_back

    # Word navigation: Alt+B/F (emacs) and Alt+Left/Right (modern)
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word
    bindkey '^[[1;3D' backward-word  # Alt+Left
    bindkey '^[[1;3C' forward-word   # Alt+Right

    # Directory navigation: Alt+Up (cd ..) and Alt+Down (cd -)
    bindkey '^[[1;3A' _cd_up          # Alt+Up - xterm style (iTerm, SSH, Linux)
    bindkey '^[[1;3B' _cd_back        # Alt+Down - xterm style
    bindkey '^[[1;5A' _cd_up          # Alt+Up - VS Code terminal (sends Ctrl modifier)
    bindkey '^[[1;5B' _cd_back        # Alt+Down - VS Code terminal

    # Terminal-specific bindings
    case "$TERM_PROGRAM" in
    Apple_Terminal)
        bindkey '^[^?' backward-kill-word
        bindkey '^[^[OA' _cd_up           # Option+Up (cd ..) - Terminal.app style
        bindkey '^[^[OB' _cd_back         # Option+Down (cd -)
        ;;
    esac

    # Ghost suggestion from history as you type.
    [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
      source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    # Must be sourced last: it wraps zle widgets, so anything defining widgets
    # after this point won't get highlighted.
    [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
      source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
