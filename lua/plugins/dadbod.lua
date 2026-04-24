vim.pack.add({
	{ src = "https://github.com/tpope/vim-dadbod" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
})

vim.g.dbs = {
	postgres_local = "postgres://enot:risimo66@127.0.0.1:5432/my_db",
}

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_help = 1
vim.g.db_ui_default_query = "select * from {table} limit 100"
vim.g.db_ui_execute_on_save = 0
vim.g.db_ui_use_nvim_notify = 1

vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod"   
vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/dadbod/tmp" -- папка для временных запросов

vim.keymap.set("n", "<leader>dbu", "<Cmd>DBUIToggle<CR>", { desc = "Toggle DBUI" })

