-- Format PHP with the project's own Laravel Pint (vendor/bin/pint, pint.json)
-- instead of the lang.php extra's default php_cs_fixer, which ignores project
-- config. conform.nvim ships a "pint" formatter that already resolves
-- vendor/bin/pint from the project root.
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "pint" },
      },
    },
  },
}
