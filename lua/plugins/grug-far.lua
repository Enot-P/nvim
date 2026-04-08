vim.pack.add({
	{ src = "https://github.com/MagicDuck/grug-far.nvim" },
})

require("grug-far").setup({})

vim.keymap.set("n", "<leader>fR", "<cmd>GrugFar<cr>", { desc = "GrugFar: find & replace" })
vim.keymap.set("v", "<leader>fR", "<cmd>GrugFarWithin<cr>", { desc = "GrugFar: within selection" })
