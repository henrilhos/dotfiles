{ pkgs, user, ... }:
{
  imports = [
    ./fish.nix
    ./git.nix
    ./gh.nix
    ./tmux.nix
    ./tmuxinator.nix
    ./ghostty.nix
    ./neovim.nix
    ./karabiner.nix
    ./vscode.nix
    ./ssh.nix
    ./gpg.nix
    ./mise.nix
  ];

  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Everything that used to be a `brew "..."` line in dotfiles/.Brewfile, minus
  # the tools that get their own home-manager module below (fish, git, gh, tmux,
  # fzf, zoxide, mise, neovim) and minus the two nixpkgs cannot build — those
  # are in modules/darwin/homebrew.nix.
  home.packages =
    with pkgs;
    [
      # Core CLI
      bat
      eza
      fd
      ripgrep
      jq
      curl
      gnutar
      onefetch

      # Git and containers
      lazygit
      lazydocker

      # Terminal
      sesh
      tmuxinator
      yazi

      # Languages and toolchains. mise (modules/home/mise.nix) still owns node
      # and java; these are the ones that were pinned by Homebrew.
      php83
      php83Packages.composer
      cocoapods
      watchman
      tree-sitter
      markdownlint-cli
      k6

      # Build dependencies that were explicit in the Brewfile
      autoconf
      automake
      bison
      libpq
      openssl
      pkg-config
      re2c

      # Misc
      gnumeric
      rtk
      claude-code
    ]
    ++ [
      # The sesh picker, previously dotfiles/.config/bin/sesh_start.
      (writeShellApplication {
        name = "sesh_start";
        runtimeInputs = [
          sesh
          fzf
          fd
          tmux
        ];
        text = ''
          sesh connect "$(
            sesh list --icons | fzf --no-border \
              --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
              --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
              --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
              --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
              --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
              --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
              --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
              --preview-window 'right:55%' \
              --preview 'sesh preview {}'
          )"
        '';
      })
    ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ANDROID_HOME = "$HOME/Library/Android/sdk";
    BUN_INSTALL = "$HOME/.bun";
    # mise reads .node-version and friends, but not a repo's .tool-versions.
    MISE_OVERRIDE_TOOL_VERSIONS_FILENAME = "none";
    # Husky installs git hooks on `npm install`; not wanted on this machine.
    HUSKY = "0";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/Library/Android/sdk/emulator"
    "$HOME/Library/Android/sdk/platform-tools"
    # Still needed for the cask CLIs and the two brews in
    # modules/darwin/homebrew.nix.
    "/opt/homebrew/bin"
  ];

  # Shell-integrated tools that were `eval`/`source` lines in config.fish.
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd -H -E '.git'";
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

}
