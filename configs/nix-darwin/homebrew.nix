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
    ];

    # GUI apps. Add one line per package, e.g. "ghostty", "raycast".
    casks = [
      "ghostty"
    ];
  };
}
