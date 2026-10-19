# Applied only to hosts flagged `personal = true` in flake.nix: apps that
# stay off the work Mac. Lists merge with the shared ones in homebrew.nix.
{ ... }:
{
  homebrew.casks = [
    "datagrip"
    "discord"
    "prismlauncher"
  ];
}
