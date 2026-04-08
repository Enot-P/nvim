vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/creativenull/efmls-configs-nvim" },
})

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "bashls", "gopls", "efm" },
	automatic_enable = false,
})
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"efm",
		"stylua",
		"gopls",
		"delve",
		"golangci-lint",
		-- efm (efmls-configs checkhealth): линтеры/форматтеры должны быть в PATH (= mason/bin)
		-- "luacheck",
		"shellcheck",
		"shfmt",
		"prettierd",
		"eslint_d",
		"fixjson",
		-- Kulala: форматирование JS/HTML в ответах; grug-far: движок ast-grep
		"prettier",
		"ast-grep",
	},
})

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })
local blink_ok, blink = pcall(require, "blink.cmp")
local capabilities = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

---@param bufnr integer
---@return fun(client: vim.lsp.Client): boolean|nil
local function formatting_filter(bufnr)
	local ft = vim.bo[bufnr].filetype
	if ft == "http" or ft == "rest" then
		return function(c)
			return c.name == "kulala"
		end
	end
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if c:supports_method("textDocument/formatting") and c.name == "efm" then
			return function(cl)
				return cl.name == "efm"
			end
		end
	end
	return nil
end

-- Format on save (реальные файлы; efm или kulala)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua",
		"*.json",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.http",
		"*.rest",
	},
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		if not vim.bo[args.buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end
		local has_any_formatter = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c:supports_method("textDocument/formatting") then
				has_any_formatter = true
				break
			end
		end
		if not has_any_formatter then
			return
		end
		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 5000,
			filter = formatting_filter(args.buf),
		})
	end,
})

local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	-- CodeLens: Neovim 0.13+ рекомендует enable() вместо refresh({bufnr=...}).
	-- Включаем только для gopls, чтобы не менять поведение остальных LSP.
	if client.name == "gopls" and client:supports_method("textDocument/codeLens", bufnr) then
		pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr })
	end

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})
vim.lsp.config("bashls", { capabilities = capabilities })

do
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")

	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d = require("efmls-configs.linters.eslint_d")

	local fixjson = require("efmls-configs.formatters.fixjson")

	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")

	vim.lsp.config("efm", {
		capabilities = capabilities,
		filetypes = {
			"json",
			"jsonc",
			"lua",
			"markdown",
			"sh",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				json = { eslint_d, fixjson },
				jsonc = { eslint_d, fixjson },
				lua = { luacheck, stylua },
				markdown = { prettier_d },
				sh = { shellcheck, shfmt },
			},
		},
	})
end

vim.lsp.enable({
	"lua_ls",
	"bashls",
	"efm",
})
