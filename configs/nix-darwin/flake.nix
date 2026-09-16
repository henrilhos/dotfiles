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
      hosts = {
        "Henriques-MacBook-Pro" = {
          username = "henrilhos";
          alias = "personal";
        };
        "MAC-JYRCQWVHW0" = {
          username = "henrique.castilhos";
          alias = "work";
        };
      };

      mkDarwin =
        host:
        nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            ./homebrew.nix
            ./macos.nix
            { system.primaryUser = host.username; }
          ];
        };
    in
    {
      darwinConfigurations =
        lib.mapAttrs (_hostname: mkDarwin) hosts
        // lib.mapAttrs' (_hostname: host: lib.nameValuePair host.alias (mkDarwin host)) hosts;
    };
}
