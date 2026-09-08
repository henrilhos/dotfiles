-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Line wrapping
vim.opt.wrap = true -- wrap long lines instead of scrolling horizontally
vim.opt.linebreak = true -- wrap at word boundaries instead of mid-word
vim.opt.breakindent = true -- keep wrapped lines visually indented to match the start of the line

-- Spell check
vim.opt.spell = true -- enable spell checking
vim.opt.spelllang = { "en", "pt_br" } -- check spelling against English and Brazilian Portuguese

-- Editorconfig overrides
-- disable insert_final_newline so editorconfig doesn't force/strip trailing newlines
require("editorconfig").properties.insert_final_newline = function() end

-- PHP LSP: intelephense (Node-based) instead of the default phpactor (PHP-based) —
-- there's no PHP runtime on the host, projects run it inside Docker/Sail.
vim.g.lazyvim_php_lsp = "intelephense"
