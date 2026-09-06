-- Dracula PRO (dark) / Alucard (light). Private repo — lazy.nvim clones it
-- like any other plugin (into its own data dir, not this repo), using
-- the same SSH access as everything else in configs/ssh/config.
--
-- cormacrelf/dark-notify picks between the two colorschemes to mirror the
-- macOS Appearance setting, the same signal driving Ghostty's `theme` and
-- tmux's tmux-dark-notify (configs/ghostty/config, configs/tmux/tmux.conf).
-- It shells out to the `dark-notify` CLI (configs/nix-darwin/homebrew.nix)
-- to watch for the switch.
return {
  {
    "dracula-pro/vim",
    name = "dracula-pro",
    url = "git@github.com:dracula-pro/vim.git",
    lazy = false,
    priority = 1000,
  },
  {
    "cormacrelf/dark-notify",
    lazy = false,
    priority = 1000,
    dependencies = { "dracula-pro" },
    config = function()
      require("dark_notify").run({
        schemes = {
          dark = "dracula-pro",
          light = "dracula-pro-alucard",
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "dracula-pro" },
  },
}
