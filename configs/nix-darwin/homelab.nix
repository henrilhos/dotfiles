# Applied only to hosts flagged `homelab = true` in flake.nix: names the
# machine after its flake key. Homelab docs
# (naming scheme, hosts, log) live in ~/Code/henrilhos/homelab.
hostname: {
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };
}
