# Applied only to hosts flagged `work = true` in flake.nix: apps that stay
# off the personal Mac. Lists merge with the shared ones in homebrew.nix.
{ ... }:
{
  homebrew.casks = [ "dbeaver-community" ];
}
