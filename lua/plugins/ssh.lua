-- =============================================
-- remote-nvim.nvim + Snacks + минимальный Telescope
-- =============================================

vim.pack.add({
	-- Обязательные зависимости remote-nvim
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",

	-- Telescope — нужен remote-nvim (пока без него не работает)
	"https://github.com/nvim-telescope/telescope.nvim",

	{
		src = "https://github.com/amitds1997/remote-nvim.nvim",
		name = "remote-nvim",
	},
})

-- ── Настройка после загрузки ─────────────────────────────────────
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
