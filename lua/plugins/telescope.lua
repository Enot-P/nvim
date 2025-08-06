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

		-- Клавишные комбинации
		vim.keymap.set("n", "<leader>tb", builtin.buffers, { desc = "Поиск по буферам" })
		vim.keymap.set("n", "<leader>to", builtin.oldfiles, { desc = "Поиск по истории файлов" })
		vim.keymap.set("n", "<leader>tlb", function()
			builtin.git_branches({ show_remote_tracking_branches = false })
		end, { desc = "Поиск по локальным веткам git" })
		vim.keymap.set("n", "<leader>tlrb", builtin.git_branches, { desc = "Поиск по всем веткам git" })
		vim.keymap.set("n", "<leader>tgg", require("telescope").extensions.live_grep_args.live_grep_args, { desc = "Поиск по файлам (live grep)" })
		vim.keymap.set("n", "<leader>tgs", builtin.grep_string, { desc = "Поиск слова под курсором" })
		vim.keymap.set("n", "<leader>th", builtin.help_tags, { desc = "Поиск по тегам помощи" })
		vim.keymap.set("n", "<leader>tc", builtin.commands, { desc = "Поиск по командам" })
		vim.keymap.set("n", "<leader>ts", builtin.lsp_document_symbols, { desc = "Поиск по символам в документе" })
		vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "Поиск по файлам" })
		vim.keymap.set("n", "<C-p>", project_files, { desc = "Поиск по файлам проекта" })

		-- Настройка Telescope
		telescope.setup({
			defaults = require("telescope.themes").get_dropdown({
				file_sorter = require("telescope.sorters").get_fzy_sorter,
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				-- Настраиваем vimgrep_arguments для поиска скрытых файлов
				vimgrep_arguments = vimgrep_arguments,
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
				["ui-select"] = {
					specific_opts = {
						codeactions = false,
					},
				},
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
