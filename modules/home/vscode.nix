{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  userDir = "Library/Application Support/Code/User";
in
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      userSettings = {
        "editor.accessibilitySupport" = "off";
        "editor.minimap.enabled" = false;
        "git.confirmSync" = false;
        "agents.voice.language" = "pt";
        "cSpell.enabledFileTypes"."markdown" = true;
        "cSpell.language" = "en,pt,pt_BR";
      };

      # The two cspell dictionary packs that used to be `vscode "..."` lines in
      # the Brewfile (code-spell-checker-cspell-bundled-dictionaries and
      # code-spell-checker-portuguese-brazilian) have no nixpkgs attribute, so
      # they stay marketplace installs. mutableExtensionsDir defaults to true,
      # which is what lets them coexist with the pinned ones below.
      extensions = with pkgs.vscode-extensions; [
        anthropic.claude-code
        vscodevim.vim
        streetsidesoftware.code-spell-checker
      ];
    };
  };

  # The cspell custom dictionary. Left as a writable out-of-store symlink rather
  # than a generated file because the extension appends to it whenever you pick
  # "Add word to dictionary" — a store copy would make that silently fail.
  home.file."${userDir}/cspell.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/vscode/cspell.json";
}
