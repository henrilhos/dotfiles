return {
  "adalessa/laravel.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
  },
  ft = { "php", "blade" },
  event = { "BufEnter composer.json" },
  opts = {
    features = {
      pickers = { provider = "snacks" }, -- usa snacks.picker (já instalado; sem telescope)
    },
  },
}
