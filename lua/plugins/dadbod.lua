return {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-completion" },
    -- vimscript-плагин читает g:-переменные при загрузке, поэтому всё в init
    init = function()
        local ok, dbs = pcall(dofile, vim.fn.stdpath("config") .. "/local/database_connections.lua")
        vim.g.dbs = ok and dbs or {}

        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_show_help = 1
        vim.g.db_ui_default_query = "select * from {table} limit 100"
        vim.g.db_ui_execute_on_save = 0
        vim.g.db_ui_use_nvim_notify = 1

        vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod"
        vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/dadbod/tmp" -- папка для временных запросов

        vim.keymap.set("n", "<leader>dbu", "<Cmd>DBUIToggle<CR>", { desc = "Toggle DBUI" })
    end,
}
