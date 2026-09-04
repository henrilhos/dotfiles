# dark2026 — VS Code 2026 Dark, composed include chain
# 2026-dark.json -> dark_modern.json -> dark_plus.json -> dark_vs.json
#
# Every value resolves from lua/vs2026/palette.lua in
# github.com/henrilhos/vs2026.nvim. The VS Code key each colour comes from is
# noted inline. One palette, two consumers: ghostty.nix and tmux.nix.
{
  ghostty = {
    # ANSI 0-15
    palette = [
      "0=#000000"
      "1=#cd3131"
      "2=#0dbc79"
      "3=#e5e510"
      "4=#2472c8"
      "5=#bc3fbc"
      "6=#11a8cd"
      "7=#e5e5e5"
      "8=#666666"
      "9=#f14c4c"
      "10=#23d18b"
      "11=#f5f543"
      "12=#3b8eea"
      "13=#d670d6"
      "14=#29b8db"
      "15=#e5e5e5"
    ];

    background = "#121314";
    foreground = "#cccccc";
    cursor-color = "#bbbebf";
    cursor-text = "#121314";
    selection-background = "#245c73";
    selection-foreground = "cell-foreground";
    split-divider-color = "#272829";
  };

  # Flavor values for the catppuccin/tmux plugin, remapped onto the same
  # palette. catppuccin drives status-style from @thm_mantle and popup-style
  # from @thm_bg, so mantle carries statusBar.background and bg carries the
  # widget background — mapping mantle to editor.background instead would make
  # the bar the same shade as the pane it sits under.
  tmux = {
    thm_bg = "#202122"; # editorWidget / menu / quickInput.background
    thm_fg = "#bfbfbf"; # foreground

    thm_rosewater = "#d7ba7d"; # constant.character.escape
    thm_flamingo = "#ffa198"; # markup.deleted
    thm_pink = "#da70d6"; # editorBracketHighlight.foreground2
    thm_mauve = "#c586c0"; # keyword.control
    thm_red = "#ff7b72"; # keyword
    thm_maroon = "#d16969"; # regex character class
    thm_peach = "#ffa657"; # entity.name / variable
    thm_yellow = "#dcdcaa"; # support.function
    thm_green = "#7ee787"; # entity.name.tag / markup.inserted
    thm_teal = "#4ec9b0"; # entity.name.type / support.class
    thm_sky = "#a5d6ff"; # string
    thm_sapphire = "#79c0ff"; # constant / support
    thm_blue = "#569cd6"; # constant.language
    thm_lavender = "#d2a8ff"; # entity.name.function

    thm_subtext_1 = "#969696"; # editorInlayHint.foreground
    thm_subtext_0 = "#bbbebf"; # editor.foreground
    thm_overlay_2 = "#8c8c8c"; # descriptionForeground
    thm_overlay_1 = "#626363"; # editorGhostText.foreground
    thm_overlay_0 = "#555555"; # disabledForeground
    thm_surface_2 = "#414243"; # editorSuggestWidget.selectedBackground
    thm_surface_1 = "#333536"; # input.border / dropdown.border
    thm_surface_0 = "#2a2b2c"; # widget.border / menu.border / statusBar.border
    thm_mantle = "#191a1b"; # statusBar.background
    thm_crust = "#0c0c0d"; # editor.background dimmed
  };
}
