return {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
        local ls = require("luasnip")
        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local f = ls.function_node

        -- Python snippets
        ls.add_snippets("python", {
            s("ifmain", {
                t({ 'if __name__ == "__main__":', '\t' }),
                i(1, "pass"),
            }),
            s("print", {
                t("print("),
                i(1, ""),
                t(")"),
            }),
        })

        -- Lua snippets
        ls.add_snippets("lua", {
            s("fn", {
                t("local function "),
                i(1, "name"),
                t("("),
                i(2, ""),
                t({ ")", "\t" }),
                i(3, ""),
                t({ "", "end" }),
            }),
            s("for", {
                t("for "),
                i(1, "i"),
                t(" = "),
                i(2, "1"),
                t(", "),
                i(3, "n"),
                t({ " do", "\t" }),
                i(4, ""),
                t({ "", "end" }),
            }),
        })

        -- Global snippets (работают во всех файлах)
        ls.add_snippets("all", {
            s("todo", {
                t("TODO: "),
                i(1, "description"),
            }),
        })

        -- Загрузить существующие сниппеты (если есть в папке)
        ls.filetype_extend("javascript", { "html", "css" })
    end,
}
