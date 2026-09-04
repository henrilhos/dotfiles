return {
  -- Syntax + filetype para .blade.php (highlighting confiável)
  { "jwalton512/vim-blade" },

  -- Ferramentas via Mason (intelephense é auto-instalado pela lista de servers do LSP).
  -- pint e phpstan NÃO entram aqui: instalam via Composer e são project-local
  -- (vendor/bin), com versão fixada no composer.json de cada projeto Laravel.
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "blade-formatter", -- formatter Blade (npm)
        "rustywind", -- ordena classes Tailwind em Blade (binário)
      },
    },
  },

  -- Formatação: Pint do projeto (vendor/bin/pint) para PHP,
  -- blade-formatter + rustywind para Blade
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.php = { "pint" }
      opts.formatters_by_ft.blade = { "blade-formatter", "rustywind" }
      opts.formatters = opts.formatters or {}
      opts.formatters.pint = {
        command = function(_, ctx)
          local root = vim.fs.root(ctx.dirname, "composer.json")
          if root then
            local bin = root .. "/vendor/bin/pint"
            if vim.fn.executable(bin) == 1 then
              return bin
            end
          end
          return "pint" -- fallback: pint no PATH (ex.: composer global)
        end,
        args = { "$FILENAME" },
        stdin = false,
      }
    end,
  },

  -- Lint: troca phpcs (default do extra PHP) por phpstan do projeto (vendor/bin)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        php = { "phpstan" },
      },
      linters = {
        phpstan = {
          cmd = function()
            local root = vim.fs.root(0, "composer.json")
            if root then
              local bin = root .. "/vendor/bin/phpstan"
              if vim.fn.executable(bin) == 1 then
                return bin
              end
            end
            return "phpstan" -- fallback: phpstan no PATH
          end,
        },
      },
    },
  },

  -- LSP: Tailwind dentro de Blade + ajustes do intelephense
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          filetypes_include = { "blade" },
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = { "@?class\\(([^]*)\\)", "'([^']*)'" },
              },
            },
          },
        },
        -- ajustes do intelephense para projetos Laravel grandes
        intelephense = {
          settings = {
            intelephense = {
              files = { maxSize = 5000000 },
              -- licenceKey = "...", -- opcional: recursos premium do intelephense
            },
          },
        },
      },
    },
  },

  -- Treesitter: php já vem do extra; blade é opcional (vim-blade já cobre highlight)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "php" } },
  },
}
