return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters_by_ft = {
                sql = { "pg_format" },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 3000,
            },
        })

        -- Клавиша для форматирования
        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range" })
    end,
}
