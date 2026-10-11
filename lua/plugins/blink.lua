return {
    "saghen/blink.cmp",
    -- build не нужен: на релизном теге blink сам скачивает собранный
    -- fuzzy-матчер (prebuilt binary), cargo для этого не требуется.
    version = "1.*",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
        require("blink.cmp").setup({
            keymap = {
                preset = "default",

                ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
                ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation" },
                ["<C-e>"] = { "hide" },
                ["<C-d>"] = { "scroll_documentation_down" },
                ["<C-u>"] = { "scroll_documentation_up" },
            },
            -- Раскрываем сниппеты через LuaSnip, а не через нативный vim.snippet.
            -- У vim.snippet одна сессия на буфер: вариант от gopls, приходящий в
            -- snippet-формате (функции, auto_brackets), затирал активный сниппет, и
            -- Tab после этого вставлял табуляцию вместо прыжка по табстопам.
            -- У LuaSnip сессии складываются в стек, вложенный сниппет внешний не рушит.
            snippets = { preset = "luasnip" },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                accept = {
                    auto_brackets = { enabled = true },
                },
                documentation = { auto_show = true },
                ghost_text = { enabled = true },

                menu = {
                    draw = {
                        treesitter = { "lsp" },
                        columns = {
                            { "kind_icon" },
                            { "label", "label_description", gap = 1 },
                            { "source_name" },
                        },
                    },
                },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
        })
    end,
}
