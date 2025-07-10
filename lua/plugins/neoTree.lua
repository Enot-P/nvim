return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- Рекомендуется для отображения иконок
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim", -- Опционально для поддержки предпросмотра изображений
	},
	config = function()
		require("neo-tree").setup({
			-- Источники для отображения в NeoTree
			sources = { "filesystem", "buffers", "git_status" },

			-- Типы файлов, которые не заменяются при открытии
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },

			-- Настройки файловой системы
			filesystem = {
				bind_to_cwd = false, -- Не привязываться к текущей рабочей директории
				follow_current_file = { enabled = true }, -- Следить за текущим файлом
				use_libuv_file_watcher = true, -- Использовать libuv для отслеживания изменений
			},

			-- Настройки окна
			window = {
				position = "left", -- Положение окна (можно изменить на "right")
				width = 40, -- Ширина окна
				mappings = {
					["l"] = "open", -- Открыть файл или директорию
					["h"] = "close_node", -- Закрыть текущий узел
					["<space>"] = "none", -- Отключить действие для пробела
					["Y"] = "copy_path_to_clipboard", -- Копировать путь в буфер обмена
					["O"] = "open_with_system_app", -- Открыть файл в системном приложении
					["P"] = { "toggle_preview", config = { use_float = false } }, -- Переключить предпросмотр
				},
			},

			-- Конфигурация компонентов по умолчанию
			default_component_configs = {
				indent = {
					with_expanders = true, -- Показывать индикаторы для директорий
					expander_collapsed = "", -- Иконка для свернутых директорий
					expander_expanded = "", -- Иконка для развернутых директорий
					expander_highlight = "NeoTreeExpander", -- Подсветка индикаторов
				},
				git_status = {
					symbols = {
						unstaged = "󰄱", -- Символ для незакоммиченных изменений
						staged = "󰱒", -- Символ для закоммиченных изменений
					},
				},
			},
		})

		vim.keymap.set("n", "<leader>t", ":Neotree toggle<CR>", { desc = "Переключить NeoTree" })
	end,
}
