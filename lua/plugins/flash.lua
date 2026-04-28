vim.pack.add({
    { src = "https://github.com/folke/flash.nvim" },
})

local flash = require("flash")

require("flash").setup({})

local opts = { noremap = true, silent = true, nowait = true }

vim.keymap.set({ "n", "x", "o" }, "ss", function() flash.jump() end, opts)
vim.keymap.set({ "n", "x", "o" }, "SS", function() flash.treesitter() end, opts)
vim.keymap.set("o", "r", function() flash.remote() end, opts)
vim.keymap.set("c", "<c-s>", function() flash.toggle() end, opts)
