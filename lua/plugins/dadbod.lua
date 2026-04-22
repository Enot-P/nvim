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

-- vim.g.db_ui_table_helpers = {
-- 	postgres = {
-- 		"List",
-- 		"Describe",
-- 		"Indexes",
-- 		"Foreign Keys",
-- 		"Primary Key",
-- 		"Count",
-- 		"Size",
-- 	},
-- }

vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod"

vim.keymap.set("n", "<leader>db", "<Cmd>DBUI<CR>", { desc = "Open DBUI" })
vim.keymap.set("n", "<leader>dt", "<Cmd>DBUIToggle<CR>", { desc = "Toggle DBUI" })

