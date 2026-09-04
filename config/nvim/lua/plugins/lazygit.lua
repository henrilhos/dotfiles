return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        -- Snacks derives the lazygit theme from Neovim highlight groups, and
        -- two of its defaults do not survive vs2026.
        --
        -- inactiveBorderColor pulls FloatBorder (#2a2b2c, VS Code's
        -- widget.border). Lazygit paints panel titles and the "x of y"
        -- counters with it, not just the frame, so at 1.3:1 over the terminal
        -- background every inactive panel became unreadable. LineNr is the
        -- theme's dim-chrome gray and lands at 5.2:1.
        --
        -- activeBorderColor pulls MatchParen, which vs2026 defines with a
        -- background only, so it resolved to "bold" with no color at all.
        theme = {
          [241] = { fg = "Comment" },
          activeBorderColor = { fg = "Title", bold = true },
          searchingActiveBorderColor = { fg = "Special", bold = true },
          inactiveBorderColor = { fg = "LineNr" },
        },
      },
    },
  },
}
