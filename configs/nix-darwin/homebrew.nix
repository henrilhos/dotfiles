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

    taps = [ "cormacrelf/tap" ];

    # CLI tools. Add one line per package, e.g. "starship", "eza", "fzf".
    brews = [
      "atuin"
      "autoconf"
      "bat"
      "bison"
      "btop"
      "bzip2"
      "colima"
      "cormacrelf/tap/dark-notify"
      "curl"
      "direnv"
      "docker"
      "docker-buildx"
      "docker-compose"
      "eza"
      "fd"
      "freetype"
      "fzf"
      "gettext"
      "gh"
      "git-delta"
      "gmp"
      "icu4c"
      "jpeg-turbo"
      "krb5"
      "lazydocker"
      "lazygit"
      "libedit"
      "libiconv"
      "libpng"
      "libpq"
      "libsodium"
      "libxml2"
      "libzip"
      "mise"
      "mole"
      "neovim"
      "oniguruma"
      "openssl@3"
      "pkg-config"
      "re2c"
      "readline"
      "ripgrep"
      "rtk"
      "sesh"
      "sqlite"
      "starship"
      "tmux"
      "webp"
      "yazi"
      "zlib"
      "zoxide"
      "zsh-autosuggestions"
      "zsh-syntax-highlighting"
    ];

    # GUI apps. Add one line per package, e.g. "ghostty", "raycast".
    casks = [
      "1password"
      "1password-cli"
      "arc"
      "claude-code"
      "font-recursive-code"
      "font-symbols-only-nerd-font"
      "ghostty"
      "google-chrome"
      "karabiner-elements"
      "raycast"
      "rectangle"
      "spotify"
      "t3-code"
      "visual-studio-code"
    ];
  };

  # Start the Colima VM at login, without Docker Desktop.
  launchd.user.agents.colima = {
    command = "/opt/homebrew/bin/colima start";
    serviceConfig = {
      RunAtLoad = true;
      EnvironmentVariables.PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    };
  };
}
