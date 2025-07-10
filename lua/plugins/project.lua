return {
	"ahmedkhalf/project.nvim",
	config = function()
		require("project_nvim").setup({
			manual_mode = false, -- do not change the current directory automatically
			detection_methods = { "lsp", "pattern" }, -- list of detection method in order of priority
			patterns = {
				".git",
				"_darcs",
				".hg",
				".bzr",
				".svn",
				"Makefile",
				"package.json",
				"mix.exs",
				".project",
				"Cargo.toml",
				"requirements.txt",
			},
			datapath = vim.fn.stdpath("data"),
		})
	end,
}
