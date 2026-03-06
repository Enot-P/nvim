return {
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        config = function()
            local ls = require("luasnip")

            ls.setup({
                -- Это удалит выделение (snippet session), если вы вышли из области сниппета
                region_check_events = "CursorMoved",
                -- Это удалит выделение, если вы вошли в режим Insert в другом месте
                delete_check_events = "InsertEnter",
            })

            -- VSCode-style snippets
            local vscode_loader = require("luasnip.loaders.from_vscode")

            -- 1. Загрузить популярные готовые сниппеты (включая Go) из friendly-snippets
            pcall(vscode_loader.lazy_load)

            -- 2. Загрузить ваши пользовательские сниппеты из stdpath("config")/snippets
            local config_snippets = vim.fn.stdpath("config") .. "/snippets"
            if vim.fn.isdirectory(config_snippets) == 1 then
                vscode_loader.lazy_load({
                    paths = { config_snippets },
                })
            end
        end,
    },
    {
        "rafamadriz/friendly-snippets",
        event = "InsertEnter",
    },
}
