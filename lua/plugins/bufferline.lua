vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/tiagovla/scope.nvim" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
})

require("scope").setup({})

require("bufferline").setup({
	options = {
		mode = "buffers",
		numbers = "none",
		separator_style = "thin",
		always_show_bufferline = true,
		show_close_icon = false,
		show_buffer_close_icons = false,
		enforce_regular_tabs = false,
		diagnostics = "nvim_lsp",
	},
})

-- Переключение буферов в верхней линии.
vim.keymap.set("n", "<A-,>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer in bufferline" })
vim.keymap.set("n", "<A-.>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer in bufferline" })
vim.keymap.set("n", "<A-<>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer in bufferline" })
vim.keymap.set("n", "<A->>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer in bufferline" })

-- Переключение tabpage через Scope.
vim.keymap.set("n", "<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab (scope)" })
vim.keymap.set("n", "<S-Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab (scope)" })
