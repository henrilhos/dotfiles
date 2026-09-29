-- Ayu (dark) / Ayu Light via Shatur/neovim-ayu.
--
-- cormacrelf/dark-notify picks between the two colorschemes to mirror the
-- macOS Appearance setting, the same signal driving Ghostty's `theme` and
-- tmux's tmux-dark-notify (configs/ghostty/config, configs/tmux/tmux.conf).
-- It shells out to the `dark-notify` CLI (configs/nix-darwin/homebrew.nix)
-- to watch for the switch.
return {
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
  },
  {
    "cormacrelf/dark-notify",
    lazy = false,
    priority = 1000,
    dependencies = { "Shatur/neovim-ayu" },
    config = function()
      require("dark_notify").run({
        schemes = {
          dark = "ayu-dark",
          light = "ayu-light",
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "ayu-dark" },
  },
}
