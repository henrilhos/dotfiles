-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.spell = true
vim.opt.spelllang = { "en", "pt_br" }

-- Word wrap habilitado por padrão (LazyVim vem com wrap = false).
-- `linebreak` quebra em espaço/pontuação em vez de no meio da palavra e
-- `breakindent` mantém a continuação alinhada com a indentação da linha.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Usa intelephense como LSP de PHP (intellisense), em vez do phpactor padrão
vim.g.lazyvim_php_lsp = "intelephense"

-- Ignora `insert_final_newline` do .editorconfig.
-- Prettier SEMPRE adiciona uma newline final (e ignora esse setting), então
-- projetos com `insert_final_newline = false` faziam o Neovim tirar a newline
-- a cada save enquanto o prettier a recolocava -> diff/linha extra no final.
-- No-op nessa propriedade mantém o default do Vim (fixendofline=true),
-- alinhado com o prettier e com os arquivos commitados.
require("editorconfig").properties.insert_final_newline = function() end
