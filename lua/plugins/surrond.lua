return {
	{
		"kylechui/nvim-surround",
		version = "*", -- Используем последнюю версию
		event = "VeryLazy", -- Загружаем плагин после старта Neovim
		config = function()
			require("nvim-surround").setup({
				-- Настройки (пример):
				keymaps = { -- Можно настроить свои сочетания клавиш
					normal = "ys",
					visual = "S",
					delete = "ds",
					change = "cs",
				},
			})
		end,
	},
}
