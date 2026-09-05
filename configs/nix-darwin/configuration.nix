{ ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin"; # Apple Silicon

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Managed by the Determinate Nix installer already; don't fight it.
  nix.enable = false;

  # Let nix-darwin manage /etc/zshrc (adds Nix env sourcing, etc.).
  programs.zsh.enable = true;

  # Backwards-compat marker for nix-darwin's own state. Do not bump this
  # after the fact without reading `darwin-rebuild changelog` first.
  system.stateVersion = 5;
}
