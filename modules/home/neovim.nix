{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  home.packages = [ pkgs.neovim ];

  # The one config in this repo that is *not* generated into the Nix store.
  #
  # LazyVim writes lazy-lock.json and lazyvim.json in place, so ~/.config/nvim
  # has to stay writable — a store copy would break `:Lazy sync`. An
  # out-of-store symlink points straight at the working tree, so edits and
  # lockfile updates land back in this repo with no rebuild.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nvim";
}
