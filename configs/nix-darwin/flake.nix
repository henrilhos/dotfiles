{
  description = "Darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nix-darwin, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      # One entry per machine. The key matches `scutil --get LocalHostName`,
      # so `darwin-rebuild switch --flake ~/dotfiles/configs/nix-darwin` picks
      # the right one with no `#name`. `alias` gives each host a second,
      # stable name to switch by (`--flake ...#work`) for when the hostname
      # changes out from under us — MDM renames work machines.
      # `homelab` applies ./homelab.nix (hostname from the key, Tailscale).
      hosts = {
        monica = {
          username = "henrilhos";
          alias = "personal";
          homelab = true;
        };
        "MAC-JYRCQWVHW0" = {
          username = "henrique.castilhos";
          alias = "work";
        };
      };

      mkDarwin =
        hostname: host:
        nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ./homebrew.nix
            ./macos.nix
            { system.primaryUser = host.username; }
          ]
          ++ lib.optional (host.homelab or false) (import ./homelab.nix hostname);
        };
    in
    {
      darwinConfigurations =
        lib.mapAttrs mkDarwin hosts
        // lib.mapAttrs' (hostname: host: lib.nameValuePair host.alias (mkDarwin hostname host)) hosts;
    };
}
