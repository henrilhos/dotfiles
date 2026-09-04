{ lib, ... }:
let
  palette = (import ./themes/dark2026.nix).ghostty;

  # Ghostty's config format is `key = value`, with repeated keys for list-valued
  # settings (palette, font-family, font-feature).
  renderSetting =
    key: value:
    if builtins.isList value then
      lib.concatMapStringsSep "\n" (v: "${key} = ${toString v}") value
    else if builtins.isBool value then
      "${key} = ${if value then "true" else "false"}"
    else
      "${key} = ${toString value}";

  renderConfig = attrs: lib.concatStringsSep "\n" (lib.mapAttrsToList renderSetting attrs) + "\n";
in
{
  # The binary comes from the Homebrew cask (nixpkgs has no darwin build for
  # ghostty), so home-manager manages the configuration only.
  programs.ghostty = {
    enable = true;
    package = null;

    settings = {
      font-family = [
        "Rec Mono Linear"
        "Symbols Nerd Font Mono"
      ];
      font-family-bold = "Rec Mono Linear Bold";
      font-family-italic = "Rec Mono Linear Italic";
      font-family-bold-italic = "Rec Mono Linear Bold Italic";

      font-feature = [
        "calt"
        "liga"
        "ss13"
      ];

      font-size = 14;
      window-inherit-font-size = true;

      # Look and feel
      adjust-cursor-thickness = 3;
      adjust-underline-position = 3;
      bold-is-bright = true;
      cursor-invert-fg-bg = true;
      cursor-opacity = 0.8;
      link-url = true;
      mouse-hide-while-typing = true;
      theme = "dark:dark2026.conf,light:Catppuccin Latte";
      window-vsync = true;

      # Behaviour
      clipboard-paste-protection = true;
      clipboard-trim-trailing-spaces = true;
      confirm-close-surface = false;
      copy-on-select = true;
      macos-auto-secure-input = true;
      macos-option-as-alt = true;
      macos-secure-input-indication = true;
      quit-after-last-window-closed = true;
      scrollback-limit = 4200;
      shell-integration = "fish";
      shell-integration-features = "cursor,sudo,title";
    };
  };

  # The dark half of the theme pair above, see themes/dark2026.nix.
  xdg.configFile."ghostty/themes/dark2026.conf".text = renderConfig palette;
}
