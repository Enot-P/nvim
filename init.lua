require("autocmds")
require("keybinds")
require("options")
require("lsp")

require("plugins.init")

vim.opt.timeoutlen = 300 -- таймаут для маппингов
vim.opt.spell = true
vim.opt.spelllang = { "ru", "en_us" }
