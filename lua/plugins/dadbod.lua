return {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-completion", "tpope/vim-dotenv" },
    -- vimscript-плагин читает g:-переменные при загрузке, поэтому всё в init
    init = function()
        -- g:dbs = local/database_connections.lua + БД из .env текущего проекта
        require("project-db").setup()

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
