vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},

	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

-- Ensure plugin is on runtimepath before requiring its modules.
pcall(vim.cmd, "packadd nvim-treesitter")

local function setup_treesitter()
	local ok, ts = pcall(require, "nvim-treesitter.configs")
	if not ok then
		return false
	end

	ts.setup({
		ensure_installed = {
			"go",
			"gomod",
			"gosum",
			"gotmpl",
			"gowork",
			"lua",
			"bash",
			"json",
			"markdown",
			"comment",
			"sql",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
		textobjects = { enable = true },
	})

	return true
end

if not setup_treesitter() then
	vim.api.nvim_create_autocmd("User", {
		pattern = "PackChanged",
		once = true,
		callback = function()
			pcall(vim.cmd, "packadd nvim-treesitter")
			setup_treesitter()
		end,
	})
end

-- HTTP/REST: парсер `kulala_http` ставит и регистрирует Kulala; vim.schedule даёт успеть инициализации.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_kulala_http", { clear = true }),
	pattern = { "http", "rest" },
	callback = function(args)
		vim.schedule(function()
			pcall(vim.treesitter.start, args.buf)
		end)
	end,
})
