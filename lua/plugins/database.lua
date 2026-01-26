return {
    "kndndrj/nvim-dbee",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    build = function()
        require("dbee").install()
    end,
    config = function()
        local dbee = require("dbee")

        dbee.setup({
            sources = {
                require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS")
            }
        })

        -- Отключаем fold для dbee буферов, чтобы избежать ошибок при закрытии
        vim.api.nvim_create_autocmd("BufEnter", {
            callback = function(args)
                local bufname = vim.api.nvim_buf_get_name(args.buf)
                if bufname:match("dbee") then
                    vim.opt_local.foldmethod = "manual"
                    vim.opt_local.foldexpr = ""
                end
            end,
        })

        vim.keymap.set("n", "<leader>da", dbee.toggle, { desc = "Открыть dbee UI" })
    end,
}
