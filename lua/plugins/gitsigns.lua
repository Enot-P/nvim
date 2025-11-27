return {
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "┃" },
					change = { text = "┃" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signcolumn = true,
				numhl = false,
				linehl = false,
				word_diff = false,
				watch_gitdir = {
					follow_files = true,
				},
				auto_attach = true,
				current_line_blame = false,
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil, -- Использовать стандартный формат
				max_file_length = 40000,
				-- on_attach = function(bufnr)
				--   local gs = require('gitsigns')
				--   local function map(mode, l, r, desc)
				--     vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				--   end
				--
				--   map('n', ']c', gs.nav_hunk('next'), 'Следующий hunk')
				--   map('n', '[c', gs.nav_hunk('prev'), 'Предыдущий hunk')
				--   map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
				--   map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
				-- end
			})
		end,
	},
}
