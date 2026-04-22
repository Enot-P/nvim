vim.pack.add({
	{ src = "https://github.com/ray-x/guihua.lua" },
	{ src = "https://github.com/ray-x/go.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
})
require("go").setup({
	lsp_keymaps = false,
	lsp_codelens = false,
	lsp_inlay_hints = { enable = false },
	lsp_diag_update_in_insert = true,
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
	dap_debug_gui = false,
	dap_debug_vt = true,
	-- ui
	run_in_floaterm = true,
	-- snippets
	luasnip = false,
	-- 🧠 кастомизация gopls без поломки дефолта
	lsp_cfg = {
		flags = {
			debounce_text_changes = 150,
		},
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

-- 🎮 dap ui (ручной контроль)
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

-- ============================================================
-- 🗄️  golang-migrate helpers
-- ============================================================

local function find_migrations_dir(callback)
	local cwd = vim.fn.getcwd()

	local found = vim.fs.find("migrations", {
		path = cwd,
		type = "directory",
		limit = math.huge,
	})

	if #found == 0 then
		local default = cwd .. "/migrations"
		vim.fn.mkdir(default, "p")
		callback(default)
		return
	end

	if #found == 1 then
		callback(found[1])
		return
	end

	-- несколько папок — показываем выбор
	Snacks.picker.select(found, {
		prompt = "📁 Выбери папку migrations",
		format = function(item)
			return item:gsub("^" .. vim.pesc(cwd) .. "/", "")
		end,
	}, function(item)
		if item then
			callback(item)
		end
	end)
end

local function migrate_create()
	Snacks.input({
		prompt = "📦 Имя миграции (например: create_users_table)",
		width = 60,
	}, function(name)
		if not name or name == "" then
			return
		end
		name = name:gsub("%s+", "_"):lower()

		find_migrations_dir(function(dir)
			local cmd = string.format(
				"migrate create -ext sql -dir %s -seq %s",
				vim.fn.shellescape(dir),
				vim.fn.shellescape(name)
			)
			local out = vim.fn.system(cmd)
			if vim.v.shell_error ~= 0 then
				vim.notify("migrate error:\n" .. out, vim.log.levels.ERROR)
			else
				vim.notify("✅ Миграция создана в " .. dir, vim.log.levels.INFO)
				local up = vim.fn.glob(dir .. "/*_" .. name .. ".up.sql")
				if up ~= "" then
					vim.cmd("edit " .. up)
				end
			end
		end)
	end)
end

-- ============================================================
-- 🎮 keymaps
-- ============================================================

vim.keymap.set("n", "<leader>gmc", migrate_create, { desc = "Migrate: create" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "gomod" },
	callback = function()
		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc })
		end
		-- run/test
		map("<leader>gorr", "<cmd>GoRun<cr>", "Run")
		map("<leader>gor", "<cmd>terminal cd %:p:h && go run . -race<cr>", "Run with race")
		map("<leader>got", "<cmd>GoTest<cr>", "Test")
		map("<leader>goT", "<cmd>GoTestFile<cr>", "Test file")
		-- codegen
		map("<leader>fs", "<cmd>GoFillStruct<cr>", "Fill struct")
		map("<leader>ie", "<cmd>GoIfErr<cr>", "If err")
		map("<leader>im", "<cmd>GoImpl<cr>", "Implement interface")
		-- navigation
		map("<leader>a", "<cmd>GoAlt<cr>", "Alt file")
		-- coverage
		map("<leader>c", "<cmd>GoCoverage<cr>", "Coverage")
		-- debug
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

-- надежный format-on-save для go (через gopls, если доступен)
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.go", "*.mod", "*.sum", "*.work" },
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].modifiable then
			return
		end
		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "gopls" or client.name == "efm"
			end,
		})
	end,
})
