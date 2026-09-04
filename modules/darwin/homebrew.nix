# What is left of Homebrew after the move to nixpkgs: GUI casks, and the three
# CLI tools nixpkgs cannot provide on aarch64-darwin.
#
# Everything else that used to live in dotfiles/.Brewfile is now in
# modules/home/default.nix. PHP's dependency chain (libpng, freetype, gettext,
# icu4c, gd, krb5, libzip, jpeg, libedit, libiconv, zlib) is gone entirely —
# those were only listed because `brew bundle dump` promotes them to top level;
# under Nix they are closure dependencies of php83 and never get named.
{ user, ... }:
{
  nix-homebrew = {
    enable = true;
    inherit user;
    # Adopt the /opt/homebrew that already exists instead of refusing to start.
    autoMigrate = true;
  };

  homebrew = {
    enable = true;

    onActivation = {
      # Deliberately not "zap" yet. Zap uninstalls anything not listed below,
      # which is the right end state but the wrong thing to do on the switch
      # that is still migrating packages out of Homebrew. Flip this once the
      # lists here are confirmed complete.
      cleanup = "none";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "fwojciec/tap" # j4c
    ];

    brews = [
      "mole" # nixpkgs `mole` is meta.broken
      "fwojciec/tap/j4c" # not packaged in nixpkgs

      # Homebrew wins on these: every one is both smaller and newer than the
      # nixpkgs build. Sizes are the nixpkgs closure, versions are
      # nixpkgs -> brew at the time of the move.
      "cocoapods" # 863 MB, ruby closure; 1.16.2 -> 1.17.0
      "gnumeric" # 1593 MB, drags in the whole GTK stack; 1.12.60 -> 1.12.61
      "markdownlint-cli" # 1556 MB of node closure for a linter; 0.48.0 -> 0.49.1
      "rtk" # 159 MB; 0.41.0 -> 0.47.0, and it moves fast
      "tmuxinator" # 804 MB, ruby closure; 3.3.7 -> 3.4.1
      "yazi" # 384 MB; 26.5.6 -> 26.9.1
    ];

    casks = [
      # Terminal — nixpkgs `ghostty` has no darwin build, so the cask stays.
      # Its configuration is still declarative, see modules/home/ghostty.nix.
      "ghostty"

      # Editors and dev tools
      # claude-code ships near-daily; nixpkgs was 13 patches behind (2.1.223
      # against 2.1.236) and cost 344 MB of node closure.
      "claude-code"
      "visual-studio-code"
      "datagrip"
      "bruno"
      "orbstack"

      # Utilities
      "1password"
      "karabiner-elements"
      "homerow"
      "raycast"
      "soundsource"

      # Browsers
      "arc"
      "google-chrome"

      # Communication and media
      "microsoft-teams"
      "obsidian"
      "spotify"
      "tidal"
    ];
  };
}
