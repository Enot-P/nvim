local M = {}
M.on_attach = function(client, bufnr)
	local opts = { buffer = bufnr }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
	if client.name == "dartls" then
		client.server_capabilities.inlayHintProvider = false
	end
end

return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local lsp_config = require("lspconfig")
			M.capabilities = require("cmp_nvim_lsp").default_capabilities()

			require("mason-lspconfig").setup({
				ensure_installed = {
					"astro",
					"tailwindcss",
					"ts_ls",
					"lua_ls",
					-- dartls НЕ включаем сюда - он настраивается в flutter-tools
				},
				-- Исключаем dartls из автоматической настройки
				automatic_installation = true,
				handlers = {
					function(server_name)
						-- Пропускаем dartls - он настроен в flutter-tools
						if server_name == "dartls" then
							return
						end
						lsp_config[server_name].setup({
							capabilities = M.capabilities,
							on_attach = M.on_attach,
						})
					end,
				},
			})

			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<leader>l", vim.diagnostic.setqflist)
			vim.keymap.set({ "n", "i" }, "<leader>h", function()
				vim.lsp.inlay_hint(0, nil)
			end)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = M.on_attach,
			})

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
			})

			-- Настраиваем только lua_ls отдельно для кастомных настроек
			lsp_config.lua_ls.setup({
				capabilities = M.capabilities,
				on_attach = M.on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			require("fidget").setup({})
		end,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "j-hui/fidget.nvim", tag = "legacy" },
		},
	},
}
