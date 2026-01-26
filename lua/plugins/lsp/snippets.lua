return {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
        local ls = require("luasnip")

        -- Загрузить только кастомные VSCode-style snippets из ~/.config/nvim/snippets
        local snippets_path = vim.fn.expand("~/.config/nvim/snippets")

        -- Проверяем, существует ли папка со snippets
        if vim.fn.isdirectory(snippets_path) == 1 then
            require("luasnip.loaders.from_vscode").lazy_load({
                paths = { snippets_path }
            })
        end

        -- Расширения для типов файлов
        ls.filetype_extend("javascript", { "html", "css" })
    end,
}
