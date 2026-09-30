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

    # CLI tools. Add one line per package, e.g. "starship", "eza", "fzf".
    brews = [
      "atuin"
      "autoconf"
      "automake"
      "bat"
      "bison"
      "btop"
      "bzip2"
      "cocoapods"
      "colima"
      "curl"
      "direnv"
      "docker"
      "docker-buildx"
      "docker-compose"
      "eza"
      "fd"
      "freetype"
      "fzf"
      "gd"
      "gettext"
      "gh"
      "git-delta"
      "gmp"
      "icu4c"
      "jpeg-turbo"
      "krb5"
      "libedit"
      "libiconv"
      "libpng"
      "libpq"
      "libsodium"
      "libtool"
      "libxml2"
      "libzip"
      "mise"
      "mole"
      "oniguruma"
      "openssl@3"
      "pkgconf"
      "re2c"
      "readline"
      "ripgrep"
      "sqlite"
      "starship"
      "webp"
      "yazi"
      "zlib"
      "zoxide"
      "zsh-autosuggestions"
      "zsh-syntax-highlighting"
    ];

    # GUI apps. Add one line per package, e.g. "ghostty", "arc".
    casks = [
      "android-commandlinetools"
      "arc"
      "claude-code@latest"
      "dbeaver-community"
      "font-recursive-code"
      "font-symbols-only-nerd-font"
      "ghostty"
      "microsoft-teams"
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
