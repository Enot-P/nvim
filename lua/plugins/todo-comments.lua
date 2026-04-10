vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/folke/todo-comments.nvim",
})

require("todo-comments").setup({
	keywords = {
		QUESTION = { icon = "? ", color = "warning", alt = { "ASK", "WHY" } },
	},
})

-- Keymaps
vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo" })
vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Prev todo" })
vim.keymap.set("n", "<leader>sta", function()
	Snacks.picker.todo_comments()
end, { desc = "Search all todo's" })
vim.keymap.set("n", "<leader>stt", function()
	Snacks.picker.todo_comments({ keywords = { "TODO" } })
end, { desc = "Search only TODO" })
