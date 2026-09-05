-- Dracula PRO (default variant). Private repo — lazy.nvim clones it
-- like any other plugin (into its own data dir, not this repo), using
-- the same SSH access as everything else in configs/ssh/config.
return {
  {
    "dracula-pro/vim",
    name = "dracula-pro",
    url = "git@github.com:dracula-pro/vim.git",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("dracula-pro")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "dracula-pro" },
  },
}
