# Applied only to hosts flagged `homelab = true` in flake.nix: names the
# machine after its flake key and joins it to the tailnet. Homelab docs
# (naming scheme, hosts, log) live in ~/Code/henrilhos/homelab.
hostname: {
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

  # Standalone app (not the `tailscale` CLI formula): runs the network
  # extension and the menu bar UI. Sign in once from the menu bar.
  homebrew.casks = [ "tailscale-app" ];
}
