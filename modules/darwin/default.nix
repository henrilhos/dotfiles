{
  pkgs,
  user,
  hostname,
  ...
}:
{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.stateVersion = 6;
  system.primaryUser = user;

  users.users.${user} = {
    home = "/Users/${user}";
    shell = pkgs.fish;
  };

  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

  # Upstream multi-user Nix is installed here (not Determinate), so nix-darwin
  # owns the daemon and /etc/nix/nix.conf. Leaving nix.enable at its default of
  # true is what makes the flakes setting below stick permanently — bootstrap.sh
  # only passes --extra-experimental-features for the very first run.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ user ];
    warn-dirty = false;
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Enabling fish at the system level is what adds it to /etc/shells; the
  # per-user configuration lives in modules/home/fish.nix.
  programs.fish.enable = true;

  fonts.packages = with pkgs; [
    recursive # Rec Mono Linear, the terminal font
    nerd-fonts.symbols-only # icon fallback for fish/tmux/nvim glyphs
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
}
