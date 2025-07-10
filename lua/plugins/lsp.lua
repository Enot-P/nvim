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
			require("mason-lspconfig").setup({
				ensure_installed = {
					"astro",
					"tailwindcss",
					"ts_ls",
					"lua_ls",
				},
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<leader>dl", vim.diagnostic.setqflist)

			vim.keymap.set({ "n", "i" }, "<C-b>", function()
				vim.lsp.inlay_hint(0, nil)
			end)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
				end,
			})

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
			})

			local dartExcludedFolders = {
				vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
				vim.fn.expand("$HOME/.pub-cache"),
				vim.fn.expand("/opt/homebrew/"),
				vim.fn.expand("$HOME/tools/flutter/"),
			}

			-- Запускаем dcmls только если он установлен
			if vim.fn.executable("dcm") == 1 then
				lsp_config["dcmls"].setup({
					capabilities = capabilities,
					cmd = { "dcm", "start-server" },
					filetypes = { "dart", "yaml" },
					settings = {
						dart = {
							analysisExcludedFolders = dartExcludedFolders,
						},
					},
				})
			end

			lsp_config["dartls"].setup({
				capabilities = capabilities,
				cmd = {
					"dart",
					"language-server",
					"--protocol=lsp",
				},
				filetypes = { "dart" },
				init_options = {
					onlyAnalyzeProjectsWithOpenFiles = false,
					suggestFromUnimportedLibraries = true,
					closingLabels = true,
					outline = false,
					flutterOutline = false,
				},
				settings = {
					dart = {
						analysisExcludedFolders = dartExcludedFolders,
						updateImportsOnRename = true,
						completeFunctionCalls = true,
						showTodos = true,
					},
				},
			})

			lsp_config.astro.setup({ capabilities = capabilities })
			lsp_config.intelephense.setup({ capabilities = capabilities })
			lsp_config.clangd.setup({ capabilities = capabilities })
			lsp_config.tailwindcss.setup({ capabilities = capabilities })
			lsp_config.ts_ls.setup({ capabilities = capabilities })

			lsp_config.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			require("fidget").setup({})
			require("dart-tools")
		end,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "j-hui/fidget.nvim", tag = "legacy" },
			"RobertBrunhage/dart-tools.nvim",
		},
	},
}
