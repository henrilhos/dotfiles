{
  description = "Darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nix-darwin, nixpkgs, ... }:
    {
      # Key matches `scutil --get LocalHostName`, so `darwin-rebuild switch
      # --flake ~/dotfiles/configs/nix-darwin` picks it up with no `#name`.
      darwinConfigurations."Henriques-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          ./configuration.nix
          ./homebrew.nix
          { system.primaryUser = "henrilhos"; }
        ];
      };
    };
}
