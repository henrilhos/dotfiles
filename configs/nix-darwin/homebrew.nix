{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "none" = don't remove anything not listed below. Once the lists
      # below are the real source of truth for every brew/cask you use,
      # you can switch this to "uninstall" (or "zap") to make brew state
      # fully declarative.
      cleanup = "none";
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
      "font-jetbrains-mono-nerd-font" # icons for LazyVim's UI (bufferline, statusline, etc.)
    ];
  };
}
