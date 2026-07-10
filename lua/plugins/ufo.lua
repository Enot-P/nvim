vim.pack.add({
    { src = "https://github.com/kevinhwang91/promise-async" },
    { src = "https://github.com/kevinhwang91/nvim-ufo" },
})

require("ufo").setup({
    -- не спрашивать фолды у LSP (textDocument/foldingRange) — часть серверов
    -- его не поддерживает и кидает UnhandledPromiseRejection. Берём treesitter.
    provider_selector = function(_, _, _)
        return { "treesitter", "indent" }
    end,
})

vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
vim.keymap.set("n", "zm", require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
