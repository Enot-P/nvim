local has_git = vim.fn.executable("git") == 1

return {

  {
    "lewis6991/gitsigns.nvim",
    cond = has_git,
		-- stylua: ignore
		keys = {
				{ ']g', ']h', desc = 'Next Hunk', remap = true },
				{ '[g', '[h', desc = 'Previous Hunk', remap = true },
				{ 'gs',           function() package.loaded.gitsigns.preview_hunk() end, desc = 'Preview hunk' },
				{ '<leader>ghtb', function() package.loaded.gitsigns.toggle_current_line_blame() end, desc = 'Toggle Git line blame' },
				{ '<leader>ghtd', function() package.loaded.gitsigns.toggle_deleted() end, desc = 'Toggle Git deleted' },
				{ '<leader>ghtw', function() package.loaded.gitsigns.toggle_word_diff() end, desc = 'Toggle Git word diff' },
				{ '<leader>ghtl', function() package.loaded.gitsigns.toggle_linehl() end, desc = 'Toggle Git line highlight' },
				{ '<leader>ghtn', function() package.loaded.gitsigns.toggle_numhl() end, desc = 'Toggle Git number highlight' },
				{ '<leader>ghts', function() package.loaded.gitsigns.toggle_signs() end, desc = 'Toggle Git signs' },
		},
		-- stylua: ignore
		opts = {
			signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
			numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
			current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
			attach_to_untracked = true,
			watch_gitdir = {
				interval = 1000,
				follow_files = true,
			},
			preview_config = {
				border = 'rounded',
			},
		},
  },
}
