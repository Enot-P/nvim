require("autocmds")
require("keybinds")
require("options")
require("terminal")
require("lsp")
require("markdown-links").setup()

require("plugins.init")

vim.opt.timeoutlen = 300 -- таймаут для маппингов
