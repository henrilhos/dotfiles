{ lib, pkgs, ... }:
let
  theme = (import ./themes/dark2026.nix).tmux;

  # `-gq` rather than `-og`: a plain reload re-applies these even if @thm_* was
  # already set by a previous flavor in this tmux server. They are emitted
  # before catppuccin's run-shell, and catppuccin sets its own defaults with
  # `-o` (only-if-unset), so these win.
  themeConf = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: ''set -gq @${name} "${value}"'') theme
  );
in
{
  programs.tmux = {
    enable = true;

    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 1000000;
    mouse = true;
    terminal = "tmux-256color";

    # The old tmux.conf never set this, but tmux infers vi from $EDITOR, and
    # EDITOR is nvim. home-manager writes mode-keys explicitly and defaults to
    # emacs, so leaving it out would quietly change copy-mode bindings.
    keyMode = "vi";

    extraConfig = ''
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      set-option -ag terminal-overrides ',xterm-256color:RGB'

      set-option -g set-titles on
      set-option -g set-titles-string "#S / #W"

      # Split in the current pane's directory.
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      set -g detach-on-destroy off # closing a session doesn't exit tmux
      set -g renumber-windows on   # renumber when any window closes
      set -g set-clipboard on
      set -g status-interval 3

      # yazi
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # Shift + Alt vim keys to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      bind-key "T" run-shell "${pkgs.sesh}/bin/sesh connect \"$(
        ${pkgs.sesh}/bin/sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(${pkgs.fd}/bin/fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""
    '';

    # Order matters here. home-manager emits the plugins as one block, each
    # entry's extraConfig directly before that plugin's run-shell, and puts the
    # module-level extraConfig above *after* the whole block.
    #
    # That is why status-right is attached to `cpu` rather than set in
    # extraConfig: it has to be assigned *after* catppuccin defines
    # @catppuccin_status_*, but *before* tmux-cpu and tmux-battery load,
    # because those two work by text-replacing their placeholders inside the
    # current status-right value. Moving it out of here breaks both silently.
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator

      {
        plugin = catppuccin;
        extraConfig = ''
          # dark2026 flavor overrides, see themes/dark2026.nix
          ${themeConf}

          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_text " #W"
          set -g @catppuccin_window_current_text " #W"
        '';
      }

      {
        plugin = cpu;
        extraConfig = ''
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_uptime}"
        '';
      }

      battery
    ];
  };
}
