-- =============================================
-- remote-nvim.nvim + Snacks + минимальный Telescope
-- =============================================


-- ── Настройка после загрузки ─────────────────────────────────────

return {
	"amitds1997/remote-nvim.nvim",
	dependencies = {
	    -- Обязательные зависимости remote-nvim
	    "nvim-lua/plenary.nvim",
	    "MunifTanjim/nui.nvim",

	    -- Telescope — нужен remote-nvim (пока без него не работает)
	    "nvim-telescope/telescope.nvim",
	},
	config = function()
		vim.schedule(function()
			-- 1. Настраиваем Telescope (минимально, только чтобы remote-nvim не падал)
			require("telescope").setup({
				defaults = {
					layout_strategy = "flex",
				},
			})

			-- 3. Настраиваем remote-nvim
			require("remote-nvim").setup({
				progress_view = { type = "split" },
				neovim_install_script_path = nil, -- опционально
				remote = {
					copy_locally = true, -- копирует твой конфиг на удалённую машину
				},
			})
		end)
	end,
}
