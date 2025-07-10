return {
	"tiagovla/tokyodark.nvim",
	name = "tokyodark",
	priority = 1000,

	config = function()
		local auto_dark_mode = require("auto-dark-mode")

		-- Функция делает фон прозрачным
		local function set_transparent_hls()
			local groups = { "Normal", "NormalNC", "NormalFloat", "SignColumn", "LineNr", "StatusLine", "TabLine", "VertSplit", "EndOfBuffer" }
			for _, group in ipairs(groups) do
				vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
			end
		end

		auto_dark_mode.setup({
			update_interval = 1000,
			set_dark_mode = function()
				vim.opt.background = "dark"
				vim.cmd("colorscheme tokyodark")
				set_transparent_hls()
			end,
			set_light_mode = function()
				vim.opt.background = "light"
				vim.cmd("colorscheme tokyodark")
				set_transparent_hls()
			end,
		})

		auto_dark_mode.init()

		-- Установим тему сразу
		vim.cmd("colorscheme tokyodark")
		set_transparent_hls()
	end,

	dependencies = {
		"f-person/auto-dark-mode.nvim",
	},
}
