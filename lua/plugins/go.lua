vim.pack.add({
	{ src = "https://github.com/ray-x/guihua.lua" },
	{ src = "https://github.com/ray-x/go.nvim" },

	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
})

require("go").setup({
	lsp_keymaps = false,
	lsp_codelens = true,
	lsp_inlay_hints = { enable = false },

	-- формат
	lsp_document_formatting = true,
	lsp_format_on_save = true,
	lsp_gofumpt = true,

	-- lint
	golangci_lint = {
		default = "standard",
	},

	-- тесты
	test_runner = "go",
	verbose_tests = true,

	-- debug
	dap_debug = true,
	dap_debug_gui = false, -- ❗ мы сами управляем UI
	dap_debug_vt = true,

	-- UI
	run_in_floaterm = true,

	-- snippets
	luasnip = true,

	-- 🧠 кастомизация gopls БЕЗ поломки дефолта
	lsp_cfg = {
		settings = {
			gopls = {
				gofumpt = true,
				staticcheck = true,
				usePlaceholders = true,
				completeUnimported = true,

				analyses = {
					unusedparams = true,
					shadow = true,
					nilness = true,
					unusedwrite = true,
				},

				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					constantValues = true,
					parameterNames = true,
				},
			},
		},
	},
})

-- 🎮 DAP UI (ручной контроль)
local dap, dapui = require("dap"), require("dapui")

dapui.setup()

dap.listeners.after.event_initialized["dapui"] = function()
	dapui.open()
end

dap.listeners.before.event_terminated["dapui"] = function()
	dapui.close()
end

dap.listeners.before.event_exited["dapui"] = function()
	dapui.close()
end

-- 🎮 KEYMAPS
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "gomod" },
	callback = function()
		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc })
		end
		-- Run/Test
		map("<leader>r", "<cmd>GoRun<cr>", "Run")
		map("<leader>t", "<cmd>GoTest<cr>", "Test")
		map("<leader>T", "<cmd>GoTestFile<cr>", "Test file")

		-- Codegen
		map("<leader>fs", "<cmd>GoFillStruct<cr>", "Fill struct")
		map("<leader>ie", "<cmd>GoIfErr<cr>", "If err")
		map("<leader>im", "<cmd>GoImpl<cr>", "Implement interface")

		-- Navigation
		map("<leader>a", "<cmd>GoAlt<cr>", "Alt file")

		-- Coverage
		map("<leader>c", "<cmd>GoCoverage<cr>", "Coverage")

		-- Debug
		map("<F5>", function()
			dap.continue()
		end, "Debug continue")
		map("<F10>", function()
			dap.step_over()
		end, "Step over")
		map("<F11>", function()
			dap.step_into()
		end, "Step into")
		map("<F12>", function()
			dap.step_out()
		end, "Step out")
		map("<leader>db", function()
			dap.toggle_breakpoint()
		end, "Breakpoint")
		map("<leader>du", function()
			dapui.toggle()
		end, "DAP UI")
	end,
})
