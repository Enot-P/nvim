vim.o.cmdheight = 1
vim.g.tiny_cmdline = {
    width = { value = "70%" },
}
vim.pack.add({ "https://github.com/rachartier/tiny-cmdline.nvim" })

-- ДИАГНОСТИКА: экспериментальный vim._core.ui2 вызывал плоское поле/мигание снизу.
-- Временно отключён. Если артефакт пропал — он и был причиной.
-- require("vim._core.ui2").enable({})
require("tiny-cmdline").setup({
    on_reposition = require("tiny-cmdline").adapters.blink,
})

vim.api.nvim_set_hl(0, "TinyCmdlineNormal", { bg = "#24273a", fg = "#cad3f5" })
vim.api.nvim_set_hl(0, "TinyCmdlineBorder", { fg = "#c6a0f6" }) -- фиолетово-розовый
