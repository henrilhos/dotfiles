{ lib, ... }:
{
  programs.ssh = {
    enable = true;
    # The blocks below are the whole config; don't append OpenSSH's own
    # defaults on top of them.
    enableDefaultConfig = false;

    # Neither file has to exist — ssh skips a missing Include — so the same
    # config works whether this machine runs OrbStack, Colima, both or neither.
    # OrbStack's only takes effect above any Host block, hence the order.
    includes = [
      "~/.orbstack/ssh/config"
      "~/.colima/ssh_config"
    ];

    settings = {
      "*" = lib.hm.dag.entryBefore [ "github.com" ] {
        # Keys live in 1Password, not on disk.
        IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
        PreferredAuthentications = "publickey";
        ServerAliveInterval = 5;
        ExitOnForwardFailure = "yes";
      };

      # Port 443 gets through networks that block 22.
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
      };
    };
  };
}
