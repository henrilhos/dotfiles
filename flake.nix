{
  description = "henrilhos' macOS configuration — nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manages the Homebrew prefix declaratively so `brew` itself stops being
    # hand-installed state. Adopts the existing /opt/homebrew, see
    # modules/darwin/homebrew.nix.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Fish plugins, pinned here instead of by fisher. Taken as sources rather
    # than from pkgs.fishPlugins because fishPlugins.fzf-fish is marked
    # meta.broken on darwin and catppuccin/fish has no nixpkgs attribute.
    fzf-fish = {
      url = "github:PatrickF1/fzf.fish";
      flake = false;
    };
    pisces = {
      url = "github:laughedelic/pisces";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";
      user = "henrilhos";
      hostname = "Henriques-MacBook-Pro";

      # Escape hatch for anything the 26.05 release branch has not caught up on.
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs unstable user hostname; };
        modules = [
          ./modules/darwin
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # First switch will find hand-written files where it wants to put
              # symlinks; move them aside instead of aborting the whole build.
              backupFileExtension = "hm-bak";
              extraSpecialArgs = { inherit inputs unstable user; };
              users.${user} = import ./modules/home;
            };
          }
        ];
      };

      # `darwin-rebuild` resolves the bare hostname on its own; this alias keeps
      # `--flake .#mac` working from a machine named something else.
      darwinConfigurations.mac = self.darwinConfigurations.${hostname};

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
