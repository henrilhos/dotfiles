{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "zap" = brew/cask state is now fully declarative: anything installed
      # but not listed in `brews`/`casks` below gets removed on every
      # `darwin-rebuild switch`, including a cask's app support files and
      # preferences (the "zap" step), not just the app itself.
      cleanup = "zap";
    };

    taps = [ ];

    # CLI tools. Add one line per package, e.g. "starship", "eza", "fzf".
    brews = [
      "bat"
      "btop"
      "direnv"
      "eza"
      "fd"
      "fzf"
      "gh"
      "git-delta"
      "lazygit"
      "mise"
      "neovim"
      "ripgrep"
      "sesh"
      "starship"
      "tmux"
      "zoxide"
    ];

    # GUI apps. Add one line per package, e.g. "ghostty", "raycast".
    casks = [
      "1password"
      "arc"
      "claude-code"
      "font-recursive-code"
      "font-symbols-only-nerd-font"
      "ghostty"
      "karabiner-elements"
      "raycast"
      "rectangle"
      "spotify"
    ];
  };
}
