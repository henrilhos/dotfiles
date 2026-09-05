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
      "neovim" # provides the `nvim` command
      "starship" # shell prompt
      "ripgrep" # required by LazyVim (telescope grep, live grep, etc.)
      "fd" # required by LazyVim (telescope file finding)
      "lazygit" # LazyVim's built-in git UI (<leader>gg)
    ];

    # GUI apps. Add one line per package, e.g. "ghostty", "raycast".
    casks = [
      "ghostty"
      "claude-code"
      "font-recursive-code" # main terminal/editor font
      "font-symbols-only-nerd-font" # icon glyphs (bufferline, statusline, etc.) layered on top
    ];
  };
}
