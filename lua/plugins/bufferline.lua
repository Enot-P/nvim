vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/tiagovla/scope.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
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
		icon_theme = "default",
	},
})

-- Переключение буферов в верхней линии.
vim.keymap.set("n", "<A-,>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer in bufferline" })
vim.keymap.set("n", "<A-.>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer in bufferline" })
vim.keymap.set("n", "<A-<>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer in bufferline" })
vim.keymap.set("n", "<A->>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer in bufferline" })

-- Закрыть все кроме текущего
vim.keymap.set("n", "<leader>bdo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close all other buffers" })
-- Закрыть все слева
vim.keymap.set("n", "<leader>bdl", "<cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
-- Закрыть все справа
vim.keymap.set("n", "<leader>bdr", "<cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })
-- Переместить буффер в новый tab
vim.keymap.set("n", "<leader>bm", "<cmd>ScopeMoveBuf<CR>", { desc = "Move buffer to tab" })

-- Переключение tabpage через Scope.
vim.keymap.set("n", "<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab (scope)" })
vim.keymap.set("n", "<S-Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab (scope)" })

vim.keymap.set("n", "<leader>btc", "<cmd>tabnew<CR>", { desc = "Next tab (scope)" })
vim.keymap.set("n", "<leader>btd", "<cmd>tabclose<CR>", { desc = "Close tab" })
