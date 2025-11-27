return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter", -- Загружаем плагин при входе в режим вставки
		opts = {}, -- Пустая конфигурация, можно настроить позже
		config = function()
			require("nvim-autopairs").setup({
				-- Настройки (пример):
				check_ts = true, -- Интеграция с treesitter (если используете)
				disable_filetype = { "TelescopePrompt", "vim" }, -- Отключить для некоторых типов файлов
			})
		end,
	},
}
