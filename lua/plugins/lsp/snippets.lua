return {
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

        -- Ваш существующий код загрузки сниппетов...
        local snippets_path = vim.fn.expand("~/.config/nvim/snippets")
        if vim.fn.isdirectory(snippets_path) == 1 then
            require("luasnip.loaders.from_vscode").lazy_load({
                paths = { snippets_path }
            })
        end
    end,
}
