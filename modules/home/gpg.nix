{ pkgs, ... }:
{
  # GPG is only here for the occasional thing that insists on a real PGP key —
  # git commit signing goes through 1Password's SSH agent, see git.nix.
  programs.gpg = {
    enable = true;

    settings = {
      default-key = "5439C6F63C0E8D0C17E534D7783DBAF23C1D6478";
      keyserver = "hkps://keys.openpgp.org";
      verbose = true;
    };
  };

  # home-manager's services.gpg-agent module is Linux-only, so the agent config
  # is written directly. pinentry now resolves to the Nix store instead of
  # /opt/homebrew/bin/pinentry-tty.
  home.file.".gnupg/gpg-agent.conf".text = ''
    # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
    pinentry-program ${pkgs.pinentry_mac}/${pkgs.pinentry_mac.binaryPath or "bin/pinentry-mac"}
    pinentry-timeout 60
    default-cache-ttl 3600
    default-cache-ttl-ssh 3600
    verbose
  '';
}
