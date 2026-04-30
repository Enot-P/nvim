vim.pack.add({ "https://github.com/stevearc/resession.nvim" })
vim.pack.add({ "https://github.com/scottmckendry/pick-resession.nvim" })

require("pick-resession").setup({})

local resession = require("resession")
resession.setup({})
-- Resession does NOTHING automagically, so we have to set up some keymaps
vim.keymap.set("n", "<leader>ss", resession.save)
vim.keymap.set("n", "<leader>sl", resession.load)
vim.keymap.set("n", "<leader>sd", resession.delete)
