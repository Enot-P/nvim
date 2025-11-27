return {
	"nvim-telescope/telescope.nvim",
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local telescopeConfig = require("telescope.config")

		-- Клонируем vimgrep_arguments для настройки поиска скрытых файлов
		local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
		-- Включаем поиск скрытых файлов
		table.insert(vimgrep_arguments, "--hidden")
		-- Исключаем директорию .git
		table.insert(vimgrep_arguments, "--glob")
		table.insert(vimgrep_arguments, "!**/.git/*")

		-- Функция для поиска файлов с резервным вариантом
		local function project_files()
			local opts = { hidden = true } -- Включаем скрытые файлы для find_files
			local ok = pcall(builtin.git_files, opts)
			if not ok then
				builtin.find_files(opts)
			end
		end

		-- Функция для поиска только ошибок LSP
		local function find_lsp_errors(opts)
			local options = vim.tbl_deep_extend("force", {
				severity = vim.diagnostic.severity.ERROR, -- Фильтр только ошибок
			}, opts or {})
			builtin.diagnostics(options)
		end

		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc })
		end

		-- Клавишные комбинации (все начинаются с <leader>t)
		map("<leader>tbb", builtin.buffers, "Telescope: буферы")
		map("<leader>tbh", builtin.oldfiles, "Telescope: недавние файлы")
		map("<leader>tff", builtin.find_files, "Telescope: поиск файлов")
		map("<leader>tfp", project_files, "Telescope: файлы проекта (git fallback)")
		map("<leader>tpp", function()
			telescope.load_extension("projects")
			telescope.extensions.projects.projects({})
		end, "Telescope: список проектов")
		map("<leader>tfg", function()
			telescope.load_extension("live_grep_args")
			telescope.extensions.live_grep_args.live_grep_args()
		end, "Telescope: живой поиск по проекту")
		map("<leader>tfs", builtin.grep_string, "Telescope: слово под курсором")
		map("<leader>tgl", function()
			builtin.git_branches({ show_remote_tracking_branches = false })
		end, "Telescope: локальные git-ветки")
		map("<leader>tga", builtin.git_branches, "Telescope: все git-ветки")
		map("<leader>thh", builtin.help_tags, "Telescope: help tags")
		map("<leader>tcc", builtin.commands, "Telescope: команды")
		map("<leader>tls", builtin.lsp_document_symbols, "Telescope: LSP символы документа")
		map("<leader>tlbd", function()
			builtin.diagnostics({ bufnr = 0 })
		end, "Telescope: LSP диагностика буфера")
		map("<leader>tlpd", function()
			builtin.diagnostics({ bufnr = nil })
		end, "Telescope: LSP диагностика проекта")
		map("<leader>tlbe", function()
			find_lsp_errors({ bufnr = 0 })
		end, "Telescope: ошибки буфера")
		map("<leader>tlpe", function()
			find_lsp_errors({ bufnr = nil })
		end, "Telescope: ошибки проекта")

		-- Настройка Telescope
		telescope.setup({
			defaults = require("telescope.themes").get_dropdown({
				file_sorter = require("telescope.sorters").get_fzy_sorter,
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				-- Настраиваем vimgrep_arguments для поиска скрытых файлов
				vimgrep_arguments = vimgrep_arguments,
				-- Увеличиваем размеры выпадающих окон
				layout_config = { width = 0.75, height = 0.6 },
				mappings = {
					i = {
						["<C-x>"] = false, -- Отключение стандартного <C-x>
						["<esc>"] = require("telescope.actions").close, -- Закрытие Telescope на <Esc>
					},
				},
			}),
			extensions = {
				fzy_native = {
					override_generic_sorter = false,
					override_file_sorter = true,
				},
				["ui-select"] = require("telescope.themes").get_dropdown({
					previewer = false,
					layout_config = { width = 0.8, height = 0.6 },
				}),
			},
		})

		-- Загрузка расширений
		telescope.load_extension("fzy_native")
		telescope.load_extension("live_grep_args")
		telescope.load_extension("ui-select")
		telescope.load_extension("projects")
	end,
	dependencies = {
		"nvim-telescope/telescope-fzy-native.nvim",
		"nvim-telescope/telescope-live-grep-args.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"ahmedkhalf/project.nvim",
	},
}
