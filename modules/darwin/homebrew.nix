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
    ];

    casks = [
      # Terminal — nixpkgs `ghostty` has no darwin build, so the cask stays.
      # Its configuration is still declarative, see modules/home/ghostty.nix.
      "ghostty"

      # Editors and dev tools
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
