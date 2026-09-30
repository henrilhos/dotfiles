{ lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin"; # Apple Silicon

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Managed by the Determinate Nix installer already; don't fight it.
  nix.enable = false;

  # /nix/store only grows otherwise. nix.gc/nix.optimise need nix.enable,
  # which we can't turn on (Determinate manages the daemon) — so just
  # clean up as part of every `darwin-rebuild switch` instead of on a
  # timer.
  system.activationScripts.postActivation.text = ''
    echo "Collecting Nix garbage older than 30 days..."
    /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 30d
    /nix/var/nix/profiles/default/bin/nix store optimise
  '';

  # Only the unfree packages listed here may be built.
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "teleport-connect";

  # Apps built by Nix; nix-darwin links them into /Applications/Nix Apps.
  environment.systemPackages = [ (pkgs.callPackage ./teleport-connect.nix { }) ];

  # Let nix-darwin manage /etc/zshrc (adds Nix env sourcing, etc.).
  programs.zsh.enable = true;

  # Backwards-compat marker for nix-darwin's own state. Do not bump this
  # after the fact without reading `darwin-rebuild changelog` first.
  system.stateVersion = 5;
}
