vim.pack.add({
	"https://github.com/stevearc/quicker.nvim",
	"https://github.com/kevinhwang91/nvim-bqf",
})

require("quicker").setup({
	keys = {
		{
			">",
			function()
				require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
			end,
			desc = "Expand quickfix context",
		},
		{
			"<",
			function()
				require("quicker").collapse()
			end,
			desc = "Collapse quickfix context",
		},
	},

	edit = {
		enabled = true,
		autosave = "unmodified",
	},

	highlight = {
		treesitter = true,
		lsp = true,
	},

	constrain_cursor = true,
	trim_leading_whitespace = "common",
})

vim.keymap.set("n", "<leader>qq", function()
	require("quicker").toggle()
end, { desc = "Toggle quickfix" })

vim.keymap.set("n", "<leader>l", function()
	require("quicker").toggle({ loclist = true })
end, { desc = "Toggle loclist" })

require("bqf").setup({
	auto_enable = true,
	preview = {
		auto_preview = true,
		winblend = 0,
		win_height = 12,
		win_vheight = 12,
		delay_syntax = 80,
		border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
	},
	-- Отключаем всё кроме превью
	auto_resize_height = false,
	magic_window = false,
	func_map = {
		open = "",
		openc = "",
		split = "",
		vsplit = "",
		tab = "",
		tabb = "",
		tabc = "",
		ptogglemode = "",
		ptoggleitem = "",
		ptoggleauto = "",
		pscrollup = "",
		pscrolldown = "",
		pscrolloriginal = "",
		prevfile = "",
		nextfile = "",
		prevhist = "",
		nexthist = "",
		lastleave = "",
		stoggleup = "",
		stoggledown = "",
		stogglevm = "",
		stogglebuf = "",
		filterr = "",
		filter = "",
		fzfsynk = "",
	},
	filter = {
		fzf = { extra_opts = {} },
	},
})
