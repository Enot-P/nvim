return {
	"ruifm/gitlinker.nvim",
	config = function()
		-- default keybind is <leader>gy
		require("gitlinker").setup()
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}
